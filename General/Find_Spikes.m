function spike_signal = Find_Spikes(signal,threshold)
% Find spikes from signal by a given threshold.
%
%       spike_signal = Find_Spikes(signal,threshold)
%
% Initially findpv2 by Jesus Perez-Ortega, Oct 2011
% Modified, May 2023

% Initialize variable
n_samples = numel(signal);
signal = reshape(signal,n_samples,1);
spike_signal = false(n_samples,1);

% Find all peaks
indices = find(signal>=threshold);

if ~numel(indices)
    disp('No spikes found!')
    return
end

% Find nonconsecutive peaks
id_nonconsecutive = find(indices~=[0; indices(1:numel(indices)-1)+1]);    % index of same peak

% Delete first if start above threshold
if min(indices)==1
    if numel(id_nonconsecutive)>1
        indices = indices(id_nonconsecutive(2):numel(indices));
        id_nonconsecutive = id_nonconsecutive(2:numel(id_nonconsecutive))-id_nonconsecutive(2)+1;
    else
        disp('No data found!')
        return
    end
end

% Delete last if ends above threshold
if max(indices)==n_samples
    if numel(id_nonconsecutive)>1
        indices = indices(1:max(id_nonconsecutive)-1);
        id_nonconsecutive = id_nonconsecutive(1:numel(id_nonconsecutive)-1);
    else
        disp('No data found!')
        return
    end
end

% number of total peaks
n_peaks = numel(id_nonconsecutive);                                       
if n_peaks
    for j = 1:n_peaks-1
        ini = indices(id_nonconsecutive(j));
        fin = indices(id_nonconsecutive(j+1)-1);
        single_peak = signal(ini:fin);
        [~,id] = max(single_peak);
        spike_signal(id+ini-1) = true;   
    end
    ini = indices(id_nonconsecutive(end));
    single_peak = signal(ini:end);
    [~,id] = max(single_peak);
    spike_signal(id+ini-1) = true;   
end