%% Preprocessing using gabor filter for image enhancement

lambda  = 9;
theta   = 0;
bw      = 3;
psi     = [0 0];
gamma   = 2;
N       = 4;
img_in = imread('a.bmp');
%img_in = double(dicomread('a.dcm'));
%img_in(:,:,2:3) = [];
img_out = zeros(size(img_in,1), size(img_in,2), N);
for n=1:N
    gb = gabor_fn(bw,gamma,psi(1),lambda,theta)...
        + gabor_fn(bw,gamma,psi(2),lambda,theta);
    img_out(:,:,n) = imfilter(img_in, gb, 'symmetric');
    theta = theta + pi/4;
end
figure(1);
imshow(img_in);
title('input image');
figure(2);
img_out_disp = sum(abs(img_out).^2, 3).^0.5;
img_out_disp = img_out_disp./max(img_out_disp(:));
imshow(img_out_disp);
title('gabor output, L-2 super-imposed, normalized');

%% This is marker controlled watershed using masking
I = img_out_disp;
se = strel('disk', 20);
Ie = imerode(I, se);
Iobr = imreconstruct(Ie, I);
Iobrd = imdilate(Iobr, se);
Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);
bw = im2bw(Iobrcbr, graythresh(Iobr));
figure
imshow(bw), title('Thresholded')
I=bw;
m = zeros(size(I,1),size(I,2));          %-- create initial mask
m(200:320,95:180) = 1;
m(186:321,348:410) = 1;
%I = imresize(I,.5);  %-- make image smaller 
%m = imresize(m,.5);  %     for fast computation
%subplot(2,2,1); imshow(I); title('Input Image');
%subplot(2,2,2); imshow(m); title('Initialization');
%subplot(2,2,3); title('Segmentation');
seg = region_seg(I, m, 1200); %-- Run segmentation
figure
imshow(seg); title('Global Region-Based Segmentation')


%% Binarization for image classification
hasil=ones(512,512);
white=0;
black=0;
for i=1:512;
    for j=1:512;
        if seg(i,j)==1
            hasil(i,j)=img_out_disp(i,j);
        else
            hasil(i,j)=1;
        end
    end
end
for i=1:512;
    for j=1:512;
        if hasil(i,j)<=0.12
                black=black+1;
            else
                white=white+1;
            end
    end
end
imshow(hasil)
threshold=17179
if black>=threshold
    ('normal lung')
else
    ('lung cancer')
end
