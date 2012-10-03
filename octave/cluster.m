addpath("octave");
addpath("octave/jsonlab");

CONFIG = loadjson("data/n0-config.json");

X = load("data/shapes.csv");

% convert the last two columns to log scale...
X = cat(2,
        X(:,1:10),
        log(X(:,11)-2),
        log(X(:,12)+1));

W = ones(1,12); % defaults
W = CONFIG.normalized_weights;
% make sure data gets normalized
W = W ./ std(X);

% apply weights
X = bsxfun( @(x,w) x .* w, X, W);

max_iters = 50;
max_K = 10;
min_delta = 1e-5;

s_max = -1;
final_centroids = [];
final_idx = [];

fprintf("Calculating mutual distances, this will take some time...");
fflush(stdout);
DIST = findMutualDistances(X);
fprintf("done\n");

for K = 2:min(max_K, size(X,1))
  initial_centroids = kMeansInitCentroids(X,K);
  [centroids, idx] = runkMeans(X, initial_centroids, max_iters, min_delta);

  S = findSilhouettes( DIST, idx );
  S_K = mean(S);

  fprintf('K-means silhouette for K=%d is %f\n', K, S_K);
  centroids;

  if S_K > s_max
    s_max = S_K;
    final_centroids = centroids;
    final_idx = idx;
  end
end

K = size(final_centroids,1);

% Save the results: typical + centroid per line
printf("\nBest clustering at K=%d, silhouette=%.2f\n", K, s_max);

% find sigma
[sigma min_d min_d_idx cluster_sizes] = computeSigma(X, final_idx, final_centroids );

fid = fopen("data/clusters.csv","w");
for i = 1:K
  rel_d = 0;
  if (sigma(i)>0.0)
    rel_d = min_d(i)/sigma(i);
  end

  printf("Cluster #%02d, Sigma: %5.2f, repr: %5d, repr dist: %5.2f = %3.1fxSigma, cluster size: %5d\n",
  i, sigma(i), min_d_idx(i),
  min_d(i), rel_d, cluster_sizes(i));

  fprintf( fid, "%d\t%g\t", min_d_idx(i), sigma(i) );
  sep = "\t";
  for j = 1:12
    if j==12
      sep = "\n";
    end
    fprintf( fid, "%g%c", final_centroids(i,j), sep );
  end
end
fclose(fid);

% save normalizing weights
fid = fopen("data/weights.csv","w");
sep = "\t";
for j = 1:12
  if j==12
    sep = "\n";
  end
  fprintf( fid, "%g%c", W(j), sep );
end
fclose(fid);


