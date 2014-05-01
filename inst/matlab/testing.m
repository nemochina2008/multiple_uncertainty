clear;
f = @(x, h) max( max((x - h),0) * (1 - max((x - h),0) ./ 100) + max((x - h),0), 0);

x_grid = linspace(0,150,151);
h_grid  = linspace(0,150,31);
y_grid  = linspace(0,150,151);
q_grid  = linspace(0,150,31);

Tmax = 10;
delta = 0.05;

%pdf = @(p,mu,s) lognpdf(p ./ mu, 0, s);
pdf = @(p,mu,s) unifpdf(p, mu .* (1 - s), mu .* (1 + s)); 


sigma_g = 0.1;
sigma_m = 0.5;
sigma_i = 0.1;
[D, V, M, I, P, Ep, F, f_matrix] =  multiple_uncertainty(f, x_grid, h_grid, Tmax, sigma_g, sigma_m, sigma_i, delta, pdf, y_grid, q_grid);

escapement = y_grid - q_grid(D(:,1));
smooth = regdatasmooth(y_grid, escapement);

figure
plot(y_grid, escapement, 'b', ...
     y_grid, smooth, 'k--')
axis([0 120 0 120])
xlabel('Fish Stock')
ylabel('Escapement')


