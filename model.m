function val = model(x, y)
    A = 7;
    val = A.*A.*exp(-4.*sqrt(x.*x + y.*y));
end
