function imgout = get_stock(imgname)
    demodir = demoimgs;
    fulldir = strcat(demodir, "/", imgname);
    imgout = imread(fulldir);
end