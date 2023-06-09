%% test 2D FFT

path(path, "../../matlab-lib");


%% test 1D first
% https://www.mathworks.com/help/signal/ug/power-spectral-density-estimates-using-fft.html

clear;

% Parameters

lam1 = 20;  % characteristic wavelength [m]
nx = 200;  % length of 1D array
fs = 1;  % sampling frequency in x

k1 = 2*pi/lam1  % corresponding wavenumber [rad/m]
nu1 = 1/lam1  % corresponding spatial frequency [/m]
% this distincion is important. In the time axis, we have sin(w*t) where w is the
% *angular* frequency, or sin(2*pi*nu*t) as in the above matlab example, where nu is the 
% *temporal* frequency. Here, the frequency domain of FFT is represented by this temporal
% frequency (nu [/s]), not the angular frequency (w [rad/s]). Similarly, in the space
% axis, we have sin(k*x) where k is the wavenumber [rad/m], or sin(2*pi*nu*x) where nu is
% the *spatial* frequency. Here, the frequency domain of FFT is represented by nu, not k.

% Array of space, x

x = (1:nx)/fs;  % sampling interval of x = 1/fs

% Array of spatial frequency, nu
%   nu of FFT is from -fs/2 to fs/2 and have the length of nx. This nu array should be
%   symmetric over nu = 0, but it has an even number of elements. 
%   See the example of Shift 1-D Signal in
%   https://www.mathworks.com/help/matlab/ref/fftshift.html for how to make nu array for
%   shifted FFT.

% nu = linspace(-fs/2+fs/nx, fs/2, nx);  % [/m]  % wrong
% nu = 0:fs/nx:fs/2;  % [/m] : as in the above matlab example. same as the above line.
nu = (-nx/2:nx/2-1)*(fs/nx);  % from the above fftshift example
k = 2*pi*nu;  % [rad/m]

% Generate y

y = cos(k1*x);  
figure;  plot(x, y);

% Obtain and plot PSD 
psd = (1/(fs*nx)) * abs(fftshift(fft(y))).^2;  % symmetric over nu=0
figure;  
subplot(211); 
plot(nu, psd);
grid on;
[m, im] = max(psd);
line(nu(im), m, marker="o");
ylabel("PSD");
xlabel(["nu [/m]", sprintf("%d-th, nu=%.3f, k=%.2f, lam=%.1f", im, nu(im), k(im), 2*pi/k(im))]);
title(sprintf("True nu=%.3f, k=%.2f, lam=%.1f", nu1, k1, lam1));
subplot(212);
nuPos = nu(nx/2:nx);  % select for nu>=0
kPos = k(nx/2:nx);
psdPos = psd(nx/2:nx);  
plot(nuPos, psdPos);
grid on;
[m, im] = max(psdPos);
line(nuPos(im), m, marker="o");
ylabel("PSD");
xlabel(["nu [/m]", sprintf("%d-th, nu=%.3f, k=%.2f, lam=%.1f", im, nuPos(im), kPos(im), 2*pi/kPos(im))]);


%% 2D FFT

clear;

% Parameters

lamX = 20;  lamY = 50;  % characteristic wavelengths in X and Y [m]
nx = 200;  ny = 250;  % length of 2D array in X and Y

fs = 1;  % sampling frequency in x and y [m]

kx1 = 2*pi/lamX;  ky1 = 2*pi/lamY;  % corresponding wavenumbers in X and Y [rad/m]
nux1 = 1/lamX;  nuy1 = 1/lamY;  % corresponding spatial frequencies in X and Y [/m]
ang1 = atan(ky1/kx1);  % characteristic angle

% Arrays of space, x and y

x = (1:nx)/fs;  
y = (1:ny)/fs;
[gx,gy] = ndgrid(x,y);

% Array of spatial frequency, nu
%   nu of FFT is from 0 to f/2 and have the length of nx/2+1, where f = sampling frequency.

% nux = linspace(-fs/2+fs/nx, fs/2, nx);  % [/m]
% nuy = linspace(-fs/2+fs/ny, fs/2, ny);  % [/m]
nux = (-nx/2:nx/2-1)*fs/nx;  % see the fftshift example
nuy = (-ny/2:ny/2-1)*fs/ny;
kx = 2*pi*nux;  % [rad/m]
ky = 2*pi*nuy;

% Generate img

img = cos(kx1*gx + ky1*gy);  
figure;  
imagesc(x, y, img');
ax = gca;
ax.YDir = "normal";
ax.DataAspectRatio = [1 1 1];  % I memorize these 4 lines to use whenever visualizing any matrix.
ax.XLabel.String = "x [m]";
ax.YLabel.String = "y [m]";

% Obtain and plot PSD 

psd = (1/(fs*nx)/(fs*ny)) * abs(fftshift(fft2(img))).^2;  % symmetric over nu=0, from -fs/2 to +fs/2
figure;  
subplot(121); 
imagesc(nux, nuy, psd');
[~, im] = FindMax(psd);  
% FindMax() is a function in our lab library. It finds max and its position (for up to 5D
% array). https://github.com/optobrain/matlab-lib
line(nux(im(1)), nuy(im(2)), marker="o", color='c');  % mark the maximum by "o"
ax = gca;
ax.YDir = "normal";  ax.DataAspectRatio = [1 1 1];
line(ax.XLim, [0 0], color='w');
line([0 0], ax.YLim, color='w');  % x and y axes
ax.YLabel.String = "\nu_y [/m]";
ax.XLabel.String = ["\nu_x [/m]", ...
    sprintf("Max at nux=%.3f, kx=%.2f, lamX=%.1f", nux(im(1)), kx(im(1)), 2*pi/kx(im(1))), ...
    sprintf("and nuy=%.3f, ky=%.2f, lamY=%.1f", nuy(im(2)), ky(im(2)), 2*pi/ky(im(2))), ...
    sprintf("and ang=%.2f [rad]", atan(ky(im(2))/kx(im(1))))];
sgtitle([sprintf("True nux=%.3f, kx=%.2f, lamX=%.1f", nux1, kx1, lamX), ...
    sprintf("and nuy=%.3f, ky=%.2f, lamY=%.1f", nuy1, ky1, lamY), ...
    sprintf("and ang=%.2f [rad]", ang1)]);
subplot(122); 
nuxPos = nux(nx/2:nx);  % nux>=0
kxPos = kx(nx/2:nx);
psdPos = psd(nx/2:nx,:);
imagesc(nuxPos, nuy, psdPos');
[~, im] = FindMax(psdPos);  
line(nuxPos(im(1)), nuy(im(2)), marker="o", color='c');  % mark the maximum by "o"
ax = gca;
ax.YDir = "normal";  ax.DataAspectRatio = [1 1 1];
line(ax.XLim, [0 0], color='w');
line([0 0], ax.YLim, color='w');  % x and y axes
ax.YLabel.String = "\nu_y [/m]";
ax.XLabel.String = ["\nu_x [/m]", ...
    sprintf("Max at nux=%.3f, kx=%.2f, lamX=%.1f", nuxPos(im(1)), kxPos(im(1)), 2*pi/kxPos(im(1))), ...
    sprintf("and nuy=%.3f, ky=%.2f, lamY=%.1f", nuy(im(2)), ky(im(2)), 2*pi/ky(im(2))), ...
    sprintf("and ang=%.2f [rad]", ang1)];

