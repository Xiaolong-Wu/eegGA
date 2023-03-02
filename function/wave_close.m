function x = wave_close(s, se)

x = wave_dilate(s, se);
x = wave_erode(x, se);
end