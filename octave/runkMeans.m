function [centroids, idx] = runkMeans(X, initial_centroids, max_iters, min_delta)
%RUNKMEANS runs the K-Means algorithm on data matrix X, where each row of X
%is a single example
%   [centroids, idx] = RUNKMEANS(X, initial_centroids, max_iters)
%   runs the K-Means algorithm on data matrix X, where each
%   row of X is a single example. It uses initial_centroids used as the
%   initial centroids. max_iters specifies the total number of interactions
%   of K-Means to execute.
%
%   runkMeans returns centroids, a Kxn matrix of the computed centroids and
%   idx, a m x 1 vector of centroid assignments (i.e. each entry in range
%   [1..K])

% Initialize values
[m n] = size(X);
K = size(initial_centroids, 1);
centroids = initial_centroids;
S = zeros(K,1);

% Run K-Means
for i=1:max_iters

    % assign memberships
    d = findDistances( X, centroids );
    [b, idx] = min(d');

    % Given new memberships, compute new centroids
    prev_centroids = centroids;
    centroids = computeCentroids(X, idx, K);

    delta_centroids = max(sumsq( centroids - prev_centroids, 2 ));

    % Output progress
    fprintf('  %d (of at most %d), delta=%g\n', i, max_iters, delta_centroids);

    if delta_centroids < min_delta
      break;
    end

end

end

