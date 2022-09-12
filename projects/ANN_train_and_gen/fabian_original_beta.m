function [alCoagulationImperial] = fabian_original_beta(params, v1, v2)


 pi = 3.1415926535897932384d0;
 boltzmann = 1.3806488d-23;     
 coef = reshape([1.44126062412083d+00, -2.85433309497245d-01,  ...
                                -1.26087336972727d-04, -1.56685886143385d-05,  ...
                                -1.28580949927114d-01, -1.21424200844139d-01,  ...
                                 4.84190814920071d+05,  3.54139071251940d+06,  ...
                                 0.50000000000000d+00,  7.81269706389624d-02],...
                                 [2, 5]);
  b1 = 0.523598775598299d0 ;
  d1 = exp(log(v1 / b1) / 3.0);
  d2 = exp(log(v2 / b1) / 3.0);
  d12 = d1 + d2;

  Kn1 = 2.0 * params(2) / d1;
  Kn2 = 2.0 * params(2) / d2;

  b1 = log(d1 / d2);
  W = 1.0 + (coef(:, 1) + coef(:, 2) * params(1)) .* exp(coef(:, 3) * b1^2 + ...
    coef(:, 5) .* log(coef(:, 4) * d12 + 1.0));

  b1 = W(1) * sqrt(pi * boltzmann * params(1) / 2.0 / 2728.9) * ...
    sqrt(1.0 / v1 + 1.0 / v2) * d12^2;

  Kn1 = 1.0 + (1.257 + 0.4d0 * exp(-1.1 / Kn1)) * Kn1;
  Kn2 = 1.0 + (1.257 + 0.4d0 * exp(-1.1 / Kn2)) * Kn2;
  b2 = W(2) * 2.0 / 3.0 * boltzmann * params(1) / params(3) * (Kn1 / d1 + ...
    Kn2 / d2) * d12;

  alCoagulationImperial = b1 * b2 / (b1 + b2);

end

