function d = findDistances( X, centroids )

% number of centroids
K = size(centroids, 1);
% number of points
m = size(X,1);

d = zeros( m, K );

for i = 1:m
  for j = 1:K
    d(i,j) = sumsq( X(i,:) - centroids(j,:) );
  end
end

end
