#!/usr/bin/python

# contour-osm -- write contour lines from a file or database source to an osm file
# Copyright (C) 2019  Roel Derickx <roel.derickx AT gmail>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import sys
import os
import argparse
import logging
import ogr2osm
from xml.dom import minidom
from osgeo import ogr
from osgeo import osr

class Polyfile:
    def __init__(self):
        self.__filename = None
        self.__name = None
        self.__polygons = ogr.Geometry(ogr.wkbMultiPolygon)


    def set_boundaries(self, minlon, maxlon, minlat, maxlat):
        self.__name = 'bbox'
        polygon = ogr.Geometry(ogr.wkbPolygon)
        poly_section = ogr.Geometry(ogr.wkbLinearRing)
        # add points in traditional GIS order (east, north)
        poly_section.AddPoint(minlon, minlat)
        poly_section.AddPoint(maxlon, minlat)
        poly_section.AddPoint(maxlon, maxlat)
        poly_section.AddPoint(minlon, maxlat)
        poly_section.AddPoint(minlon, minlat)
        polygon.AddGeometry(poly_section)
        self.__polygons.AddGeometry(polygon)


    def read_file(self, filename):
        self.__filename = filename
        self.__polygons = ogr.Geometry(ogr.wkbMultiPolygon)

        self.__read_poly()


    def __read_poly(self):
        with open(self.__filename, 'r') as f:
            self.__name = f.readline().strip()
            polygon = None
            while True:
                section_name = f.readline()
                if not section_name:
                    # end of file
                    break
                section_name = section_name.strip()
                if section_name == 'END':
                    # end of file
                    break
                elif polygon and section_name and section_name[0] == '!':
                    polygon.AddGeometry(self.__read_poly_section(f))
                else:
                    polygon = ogr.Geometry(ogr.wkbPolygon)
                    polygon.AddGeometry(self.__read_poly_section(f))
                    self.__polygons.AddGeometry(polygon)
        f.close()


    def __read_poly_section(self, f):
        poly_section = ogr.Geometry(ogr.wkbLinearRing)
        while True:
            line = f.readline()
            if not line or line[0:3] == 'END':
                # end of file or end of section
                break
            elif not line.strip():
                # empty line
                continue
            else:
                ords = line.split()
                # add point in traditional GIS order (east, north)
                poly_section.AddPoint(float(ords[0]), float(ords[1]))

        return poly_section


    def get_geometry(self, srs = 4326):
        polygons = self.__polygons.Clone()

        src_spatial_ref = osr.SpatialReference()
        src_spatial_ref.SetAxisMappingStrategy(osr.OAMS_TRADITIONAL_GIS_ORDER)
        src_spatial_ref.ImportFromEPSG(4326)

        dest_spatial_ref = osr.SpatialReference()
        dest_spatial_ref.SetAxisMappingStrategy(osr.OAMS_TRADITIONAL_GIS_ORDER)
        dest_spatial_ref.ImportFromEPSG(srs)

        transform = osr.CoordinateTransformation(src_spatial_ref, dest_spatial_ref)
        polygons.Transform(transform)

        return polygons

    '''
    def to_wkt_string(self, srs = 4326, force_eastnorth_orientation = False):
        return self.get_geometry(srs, force_eastnorth_orientation).ExportToWkt()


    def to_wkb_string(self, srs = 4326, force_eastnorth_orientation = False):
        polygons = self.get_geometry(srs, force_eastnorth_orientation)
        return ''.join(format(x, '02x') for x in polygons.ExportToWkb())
    '''



class ContourTranslation(ogr2osm.TranslationBase):
    def __init__(self, is_database_source, src_srs, poly, major_category, medium_category):
        self.logger = logging.getLogger('contour-osm')

        self.is_database_source = is_database_source
        self.src_srs = src_srs
        self.boundaries = None
        if poly:
            self.boundaries = poly.get_geometry(src_srs)
        self.major_category = major_category
        self.medium_category = medium_category

        # intersection datasource, should not go out of scope as long as the intersection layer is used
        self.intersect_ds = None


    def filter_layer(self, layer):
        if self.is_database_source or not self.boundaries:
            return layer

        spatial_ref = osr.SpatialReference()
        spatial_ref.SetAxisMappingStrategy(osr.OAMS_TRADITIONAL_GIS_ORDER)
        spatial_ref.ImportFromEPSG(self.src_srs)

        dst_driver = ogr.GetDriverByName('MEMORY')
        self.intersect_ds = dst_driver.CreateDataSource('memdata')
        dst_layer = self.intersect_ds.CreateLayer(layer.GetName(), \
                                                  srs = spatial_ref, \
                                                  geom_type = ogr.wkbMultiLineString)
        dst_layer_def = dst_layer.GetLayerDefn()

        # add input layer field definitions to the output layer
        src_layer_def = layer.GetLayerDefn()
        for i in range(src_layer_def.GetFieldCount()):
            src_field_def = src_layer_def.GetFieldDefn(i)
            dst_layer.CreateField(src_field_def)

        # add intersection of input layer features with input geometry to output layer
        amount_intersections = 0
        for j in range(layer.GetFeatureCount()):
            src_feature = layer.GetNextFeature()
            src_geometry = src_feature.GetGeometryRef()

            if self.boundaries.Intersects(src_geometry):
                amount_intersections += 1
                intersection = self.boundaries.Intersection(src_geometry)

                dst_feature = ogr.Feature(dst_layer_def)
                for k in range(dst_layer_def.GetFieldCount()):
                    dst_field = dst_layer_def.GetFieldDefn(k)
                    dst_feature.SetField(dst_field.GetNameRef(), src_feature.GetField(k))
                dst_feature.SetGeometry(intersection)

                dst_layer.CreateFeature(dst_feature)

        self.logger.info('Amount of features in source: %d', layer.GetFeatureCount())
        self.logger.info('Amount of intersections found: %d', amount_intersections)

        return dst_layer


    def filter_tags(self, attrs):
        if not attrs:
            return

        tags={}

        if 'height' in attrs:
            tags['ele'] = attrs['height']
            tags['contour'] = 'elevation'

            height = int(float(attrs['height']))
            if height % self.major_category == 0:
                tags['contour_ext'] = 'elevation_major'
            elif height % self.medium_category == 0:
                tags['contour_ext'] = 'elevation_medium'
            else:
                tags['contour_ext'] = 'elevation_minor'

        return tags



def parse_commandline():
    parser = argparse.ArgumentParser(description='Write contour lines from a file or database ' +
                                                 'source to an osm file')
    # datasource options
    parser.add_argument('--datasource', dest='datasource', help='Database connectstring or filename',
                        required = True)
    parser.add_argument('--tablename', dest='tablename',
                        help='Database table containing the contour data, only required for ' +
                             'database access.')
    parser.add_argument('--height-column', dest='heightcolumn',
                        help='Database column containg the elevation. Contour-osm will try to find ' +
                             'this column in the given table when this parameter is omitted.')
    parser.add_argument('--contour-column', dest='contourcolumn',
                        help='Database column containg the contour. Contour-osm will try to find ' +
                             'this column in the given table when this parameter is omitted.')
    # input parameters
    parser.add_argument('--src-srs', dest='srcsrs', type=int, default=4326,
                        help='EPSG code of input data. Do not include the EPSG: prefix.')
    parser.add_argument('--poly', dest='poly',
                        help='Osmosis poly-file containing the boundaries to process')
    # output parameters
    parser.add_argument('-M', '--major', dest='majorcat', metavar='CATEGORY',
                        type=int, default=500,
                        help='Major elevation category (default=%(default)s)')
    parser.add_argument('-m', '--medium', dest='mediumcat', metavar='CATEGORY',
                        type=int, default=100,
                        help='Medium elevation category (default=%(default)s)')
    parser.add_argument('--osm', dest='osm', action='store_true',
                        help='Write the output as an OSM file in stead of a PBF file')
    # required output file
    parser.add_argument("output", metavar="OUTPUT", help="Output osm or pbf file")
    params = parser.parse_args()

    params.is_database_source = params.datasource.startswith('PG:')
    if params.is_database_source and not params.tablename:
        parser.error('ERROR: tablename is required when the datasource is a database!')
    
    return params


def examine_layer(datasource, preferred_tablename, preferred_heightcol, preferred_contourcol):
    logger = logging.getLogger('contour-osm')

    logger.info("Get layer features")

    tablename = preferred_tablename
    heightcol = preferred_heightcol
    contourcol = preferred_contourcol

    layer = None
    if not preferred_tablename:
        if datasource.get_layer_count() > 0:
            (layer, reproject) = datasource.get_layer(0)
            tablename = layer.GetName()

            if datasource.get_layer_count() > 1:
                logger.warning("More than one layer found.")
        else:
            logger.error("No layer found and none was given.")
    else:
        layer = datasource.datasource.GetLayer(preferred_tablename)
    logger.info("Using layer %s", tablename)

    layerdef = layer.GetLayerDefn()

    features_without_id = \
        [ layerdef.GetFieldDefn(i).GetName() \
                for i in range(layerdef.GetFieldCount()) \
                if layerdef.GetFieldDefn(i).GetName().lower() != 'id' ]

    if preferred_heightcol and preferred_heightcol in features_without_id:
        heightcol = preferred_heightcol
    elif len(features_without_id) == 0:
        logger.error("No feature found and none was given.")
    else:
        heightcol = features_without_id[0]
        if len(features_without_id) > 1:
            logger.warning("More than one feature found.")
    logger.info("Using feature %s", heightcol)

    geoms = [ layerdef.GetGeomFieldDefn(i).GetName() \
                    for i in range(layerdef.GetGeomFieldCount()) ]
    if preferred_contourcol and preferred_contourcol in geoms:
        contourcol = preferred_contourcol
    elif len(geoms) == 0:
        logger.error("No geometry found and none was given.")
    else:
        contourcol = geoms[0]
        if len(geoms) > 1:
            logger.warning("More than one geometry found.")
    logger.info("Using geometry %s", contourcol)

    return (tablename, heightcol, contourcol)


def get_query(tablename, heightcolumn, geomcolumn, boundaries, src_srs):
    logger = logging.getLogger('contour-osm')

    sql = ''

    if boundaries:
        sql = '''select %s, ST_Intersection(%s, p.polyline)
from (select ST_GeomFromText(\'%s\', %d)  polyline) p, %s
where ST_Intersects(%s, p.polyline)''' % \
            (heightcolumn, geomcolumn, \
            boundaries.get_geometry(src_srs).ExportToWkt(), src_srs, \
            tablename, geomcolumn)
    else:
        sql = 'select %s, %s from %s' % \
            (heightcolumn, geomcolumn, tablename)

    logger.info('Generated SQL statement: %s', sql)

    return sql


def main():
    logger = logging.getLogger('contour-osm')
    logger.setLevel(logging.DEBUG)
    logger.addHandler(logging.StreamHandler())

    ogr2osmlogger = logging.getLogger('ogr2osm')
    ogr2osmlogger.setLevel(logging.ERROR)
    ogr2osmlogger.addHandler(logging.StreamHandler())

    params = parse_commandline()

    poly = None
    if params.poly:
        poly = Polyfile()
        poly.read_file(params.poly)

    # create the translation object
    translation_object = ContourTranslation(params.is_database_source, params.srcsrs, poly,
                                            params.majorcat, params.mediumcat)

    # create and open the datasource
    datasource = ogr2osm.OgrDatasource(translation_object, source_epsg=params.srcsrs, gisorder=True)
    datasource.open_datasource(params.datasource)
    if params.is_database_source:
        (table, heightcol, contourcol) = \
            examine_layer(datasource, params.tablename, params.heightcolumn, params.contourcolumn)
        query = get_query(table, heightcol, contourcol, poly, params.srcsrs)
        datasource.set_query(query)

    # convert the contour lines to osm
    osmdata = ogr2osm.OsmData(translation_object, max_points_in_way=16000)
    osmdata.process(datasource)

    #create datawriter and write OSM data
    if params.osm:
        datawriter = ogr2osm.OsmDataWriter(params.output)
        osmdata.output(datawriter)
    else:
        datawriter = ogr2osm.PbfDataWriter(params.output)
        osmdata.output(datawriter)



if __name__ == '__main__':
    main()

