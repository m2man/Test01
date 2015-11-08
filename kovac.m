function I = kovac(X)
%X = imread('C:\Users\ManhDuy\Desktop\HC.jpg');
%X = imread(filename);
R = X(:,:,1);
G = X(:,:,2);
B = X(:,:,3);

L1 = (R > 95) & (G > 40) & (B > 20);
L2 = (R - min(G,B) > 15);
L3 = (R - G > 15);
L4 = (R - B > 0);
U = L1 & L2 & L3 & L4;

L5 = (R > 220) & (G > 210) & (B > 170);
L6 = (-15 < R - G) & (R - G < 15);
L7 = (min(R,G) - B > 0);
F = L5 & L6 & L7;

I = U | F;
% subplot(1,2,1)
% imshow(X1);
% subplot(1,2,2);
% imshow(X);

