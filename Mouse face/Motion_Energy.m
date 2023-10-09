function motion_energy = Motion_Energy(movie,mask)
% Compute the average motion energy of a movie.
%
%       motion_energy = Motion_Energy(movie,mask)
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
diff_frames = diff(movie,[],2);

% Get absolute values
abs_diff = abs(diff_frames);

% Average the energy between all pixels
motion_energy(:,1) = mean(abs_diff,1);
motion_energy = [motion_energy(1); motion_energy];

