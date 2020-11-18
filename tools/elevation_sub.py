# -*- coding: utf-8 -*-
import sys
import osmium


class ElevationSubHandler(osmium.SimpleHandler):
    def __init__(self, writer):
        osmium.SimpleHandler.__init__(self)
        self.writer = writer

    def node(self, n):
        self.writer.add_node(n)
        return

    def way(self, w):
        if w.tags.get('ele', 'xx')[-1:] == '5':
            self.handle_elevation_5p(w)
            return
        elif w.tags.get('ele', 'xx')[-2:] == '50':
            self.handle_elevation_sub(w)
            return

        self.writer.add_way(w)
        return

    def relation(self, r):
        self.writer.add_relation(r)
        return

    def handle_elevation_5p(self, w):
        w = w.replace(tags=self.handle_elevation_5p_tags(w))
        self.writer.add_way(w)

    def handle_elevation_5p_tags(self, o):
        tags = dict((tag.k, tag.v) for tag in o.tags)
        tags['contour_ext'] = 'elevation_5p'
        return tags

    def handle_elevation_sub(self, w):
        w = w.replace(tags=self.handle_elevation_sub_tags(w))
        self.writer.add_way(w)

    def handle_elevation_sub_tags(self, o):
        tags = dict((tag.k, tag.v) for tag in o.tags)
        tags['contour_ext'] = 'elevation_sub'
        return tags

def main():
    if len(sys.argv) != 3:
        print("Usage: python %s <infile> <outfile>" % sys.argv[0])
        sys.exit(-1)
    infile = sys.argv[1]
    outfile = sys.argv[2]

    writer = osmium.SimpleWriter(outfile)
    handler = ElevationSubHandler(writer)
    handler.apply_file(infile)
    writer.close()


if __name__ == '__main__':
    main()
