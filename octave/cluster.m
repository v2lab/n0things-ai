addpath("octave");
Xin = load("data/points.csv");

% TODO upload current weights to the database
W = [ 1 1 1 1 1 1 1 1/255 1/255 1/255 1 1 ];

% log the last two columns and apply weights
X = bsxfun( @(x,w) x .* w, cat(2, Xin(:,1:10), log(Xin(:,11)-2), log(Xin(:,12)+1) ), W);

% FIXME this is for testing
X = X(1:100,:);

max_iters = 50;
min_delta = 1e-5;

s_max = -1;
final_centroids = [];
final_idx = [];

fprintf("Calculating mutual distances, this will take some time...");
fflush(stdout);
DIST = findMutualDistances(X);
fprintf("done\n");

for K = 2:7
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

% find typicals...
d = findDistances( X, final_centroids );
K = size(final_centroids,1);
typicals = zeros(K,1);
for j = 1:K
  [min_d, typicals(j)] = min( d(:,j) );
end

% Save the results: typical + centroid per line

fid = fopen("data/clusters.csv","w");
for i = 1:K
  fprintf( fid, "%d\t", typicals(i) );
  sep = "\t";
  for j = 1:12
    if j==12
      sep = "\n";
    end
    fprintf( fid, "%g%c", final_centroids(i,j), sep );
  end
end
fclose(fid);
