function x = wave_open(s, se)

x = wave_erode(s, se);
x = wave_dilate(x, se);
end