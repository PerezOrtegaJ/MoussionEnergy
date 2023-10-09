function intensity = Movie_Intensity(movie,mask)
% Compute the avergae motion energy of a movie.
%
%       intensity = Movie_Intensity(movie,mask)
%
%       default: mask = []
%
% By Jesus Perez-Ortega, May 2023

if nargin<2
    mask = [];
end

% Reshape movie
movie = reshape(movie,[],size(movie,3));

% Get a movie from a mask
if ~isempty(mask)
    mask = mask(:);
    movie = movie(mask,:);
end

% Get difference between consecutive frames
intensity(:,1) = mean(movie,1);