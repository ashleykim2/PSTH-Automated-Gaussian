function y = biGaussian(p, x)
    y1 = p(1) * exp(-((x - p(2)).^2) / (2 * p(3)^2));
    y2 = p(4) * exp(-((x - p(5)).^2) / (2 * p(6)^2));
    y = y1 + y2;
end
