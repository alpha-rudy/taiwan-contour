# -*- coding: utf-8 -*-
import osmium
import argparse


class ElevationSubHandler(osmium.SimpleHandler):
    def __init__(self, writer, mediumcat, majorcat, cat_tag):
        osmium.SimpleHandler.__init__(self)
        self.writer = writer
        self.mediumcat = mediumcat
        self.majorcat = majorcat
        self.cat_tag = cat_tag

    def node(self, n):
        self.writer.add_node(n)
        return

    def way(self, w):
        height = int(float(w.tags.get('height', '-1.0')))
        if height < 0:
            return

        tags = dict()
        tags['ele'] = str(height)
        tags['contour'] = 'elevation'
        if height % self.majorcat == 0:
            tags[self.cat_tag] = 'elevation_major'
        elif height % self.mediumcat == 0:
            tags[self.cat_tag] = 'elevation_medium'
        else:
            tags[self.cat_tag] = 'elevation_minor'
        
        self.writer.add_way(w.replace(tags=tags))
        return

    def relation(self, r):
        self.writer.add_relation(r)
        return

def parse_commandline():
    parser = argparse.ArgumentParser(description='Translate gdal_contour tags to pyhgtmap')
    parser.add_argument('-M', '--major', dest='majorcat', metavar='CATEGORY',
                        type=int, default=500,
                        help='Major elevation category (default=%(default)s)')
    parser.add_argument('-m', '--medium', dest='mediumcat', metavar='CATEGORY',
                        type=int, default=100,
                        help='Medium elevation category (default=%(default)s)')
    parser.add_argument('-t', '--cat_tag', dest='cat_tag', metavar='CATEGORY_TAG',
                        default='contour_ext', help='category tag (default=%(default)s)')
    parser.add_argument("infile", metavar="INPUT", help="Input from ogr2osm-ed gdal_contour tagging")
    parser.add_argument("outfile", metavar="OUTPUT", help="Output pyhgtmap-tagging")
    return parser.parse_args()

def main():
    params = parse_commandline()

    writer = osmium.SimpleWriter(params.outfile)
    handler = ElevationSubHandler(writer, params.mediumcat, params.majorcat, params.cat_tag)
    handler.apply_file(params.infile)
    writer.close()


if __name__ == '__main__':
    main()
