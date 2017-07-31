function ydata = loadDyntexDataset(fname, siz)


fdir = dir([ fname '/*.jpg']);

ydata = zeros(siz(1), siz(2), length(fdir));
for kk=1:length(fdir)
    img = imread( [fname '/' fdir(kk).name ]);
    img = double(img)/255;
    img = mean(img, 3);

    img = img(15+(1:256), 50+(1:256));
    img = imresize(img, siz, 'bilinear');
    
    ydata(:,:, kk) = img;
end