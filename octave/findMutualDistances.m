function distances = findMutualDistances(X)

N = size(X, 1);
distances = zeros(N,N);

for i = 1:N
  for j = i:N
    distances(i,j) = distances(j,i) = sumsq( X(i,:) - X(j,:) );
  end
end

end
