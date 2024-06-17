%%% ITTFA ON HPLC-DAD %%%%
nuke


%%%% concentration profiles %%%%%%%

time = 1:360;
peaks = [60,120];
widths = [22,32];
scalers = [.6,.4];
for i = 1:length(peaks)
    concentration_profiles(i,:) = scalers(i)*gaussmf(time,[widths(i),peaks(i)]);
end

%%%% spectrum profiles %%%%%%%%
base_line = 400:1200;

peaks = [600,700];
widths = [33,60];
scalers = [.7,.4];

for i = 1:length(peaks)
    pure_spectrum(i,:) = scalers(i)*gaussmf(base_line,[widths(i),peaks(i)]);
end

hplcdad = concentration_profiles' * pure_spectrum;
hplcdad = awgn(hplcdad,50);
%%%%%%%%%%%%%%%%% plots %%%%%%%%%%%%%%%%%%%%

% 
% figure('Name','pure components')
% subplot(2,1,1)
% plot(base_line,pure_spectrum)
% title('spectrum')
% subplot(2,1,2)
% plot(time,concentration_profiles)
% title('concentration')

%%%%%%%%% creating u space %%%%%%%%%%%%%%%%%%
[u, s, v] = svd(hplcdad);

for i = 1:2
    vs(i,:) = v(:,i);
end

figure('Name','u space')
scatter(vs(1,:),vs(2,:),'+')
hold on

%%%%%%% model %%%%%%

initial_concentration_profile = zeros([1 ,length(time)]) - .0001;
initial_concentration_profile(130) = .5;
pr_est = initial_concentration_profile * u(:,1:2);
reconstruct_profile = pr_est * u(:,1:2)';
estimated_concentration_profile = reconstruct_profile;
nn= 1;
%%

while min(reconstruct_profile) < 0

nn = nn+1
pr_est = estimated_concentration_profile * u(:,1:2);
figure(1)
scatter(pr_est(1),pr_est(2),90,"filled")
reconstruct_profiles = pr_est * u(:,1:2)';
reconstruct_profile = pr_est * u(:,1:2)';
for i = 1:length(reconstruct_profiles)
    if reconstruct_profiles(i) < 0
        reconstruct_profiles(i) = 0;
    end
end
figure(9)
estimated_concentration_profile = reconstruct_profiles;
plot(time,reconstruct_profile);hold on
if nn == 20
    reconstruct_profile = 0;
end
end




