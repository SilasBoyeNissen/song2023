clc; clear; rng(1);
%% PARAMETER (change accordingly)
DRAW = 1; % (Re-)draw image? 1=YES. 0=NO.
FILENAMEnematics = 'nematic lines.tif';
FILENAMEcontainingResolutionInfo = 'original image.tif';

%% SCRIPT (no changes needed below this line, hopefully)
if DRAW == 1
    % Enables drawing of two Region Of Interests (ROIs)
    figure(1); clf;
    RGB = imread(FILENAMEnematics);
    IMG = rgb2lab(RGB);
    BWall = (IMG(:, :, 2) > 1);
    imshow(BWall);
    title('Draw two Region Of Interests (ROIs)', 'FontSize', 14);
    ROI1 = createMask(drawfreehand('Color', [0.000 0.447 0.741]));
    ROI2 = createMask(drawfreehand('Color', [0.850 0.325 0.098]));
    % Calculates lengths and angles inside ROI1
    CC0 = bwconncomp(BWall == 1 & ROI1 == 1);
    RES = zeros(CC0.NumObjects, 7);
    for i = 1:CC0.NumObjects
        [y, x] = ind2sub(size(BWall), CC0.PixelIdxList{i});
        [x1, Imin] = min(x);
        [x2, Imax] = max(x);
        y1 = y(Imin);
        y2 = y(Imax);
        RES(i, :) = [1 x1 y1 x2 y2 sqrt((x2-x1)^2 + (y2-y1)^2)/imfinfo(FILENAMEcontainingResolutionInfo).XResolution -atand((y2-y1)/(x2-x1))];
    end
    % Calculates lengths and angles inside ROI2
    CC1 = bwconncomp(BWall == 1 & ROI2 == 1);
    RES = [RES; zeros(CC1.NumObjects, 7)];
    for i = CC0.NumObjects+1:CC0.NumObjects+CC1.NumObjects
        [y, x] = ind2sub(size(BWall), CC1.PixelIdxList{i-CC0.NumObjects});
        [x1, Imin] = min(x);
        [x2, Imax] = max(x);
        y1 = y(Imin);
        y2 = y(Imax);
        RES(i, :) = [2 x1 y1 x2 y2 sqrt((x2-x1)^2 + (y2-y1)^2)/imfinfo(FILENAMEcontainingResolutionInfo).XResolution -atand((y2-y1)/(x2-x1))];
    end
    % Writes lengths and angles on top of image
    for i = 1:size(RES, 1)
        if RES(i, 1) == 1
            text(RES(i, 4)+2, RES(i, 5), [sprintf('%1.1f', RES(i, 6)) ';' num2str(round(RES(i, 7))) '°'], 'Color', [0.000 0.447 0.741], 'FontSize', 10, 'FontWeight', 'bold');
        elseif RES(i, 1) == 2
            text(RES(i, 4)+2, RES(i, 5), [sprintf('%1.1f', RES(i, 6)) ';' num2str(round(RES(i, 7))) '°'], 'Color', [0.850 0.325 0.098], 'FontSize', 10, 'FontWeight', 'bold');
        end
    end
    % Saves XLS file of result dataset
    writetable(array2table(RES, 'VariableNames', {'ROI', 'x1', 'y1', 'x2', 'y2', 'Length', 'Angle'}), 'result.xls');
end

% Creates histogram of calculated lengths
RES = readmatrix([FILENAMEnematics '-result.xls']);
figure(2); clf; hold on;
set(figure(2), 'Color', 'w');
histogram(RES(RES(:, 1) == 1, 6), 0:0.25:5, 'Normalization', 'probability');
histogram(RES(RES(:, 1) == 2, 6), 0:0.25:5, 'Normalization', 'probability');
plot([mean(RES(RES(:, 1) == 1, 6)) mean(RES(RES(:, 1) == 1, 6))], [0 0.05], 'b', 'LineWidth', 10);
plot([mean(RES(RES(:, 1) == 2, 6)) mean(RES(RES(:, 1) == 2, 6))], [0 0.05], 'r', 'LineWidth', 10);
disp(['LENGTH in ROI1 = ' num2str(mean(RES(RES(:, 1) == 1, 6))) ' +- ' num2str(std(RES(RES(:, 1) == 1, 6))) ' um']);
disp(['LENGTH in ROI2 = ' num2str(mean(RES(RES(:, 1) == 2, 6))) ' +- ' num2str(std(RES(RES(:, 1) == 2, 6))) ' um']);
[~, p, D] = kstest2(RES(RES(:, 1) == 1, 6), RES(RES(:, 1) == 2, 6));
set(gca, 'Box', 'on', 'FontSize', 20, 'LineWidth', 2, 'XTick', 0:1:5, 'YTick', 0:0.1:1);
legend(['ROI1 (N=' num2str(sum(RES(:, 1) == 1)) ')'], ['ROI2 (N='  num2str(sum(RES(:, 1) == 2)) ')']);
xlabel('Length [um]')
ylabel('Frequency');
axis([0 5 0 1], 'auto y');
title(['p=' num2str(p, 3) '; D=' num2str(D, 3) '; ROI1/ROI2=' num2str(mean(RES(RES(:, 1) == 1, 6))/mean(RES(RES(:, 1) == 2, 6)), 3)])

% Creates polarhistogram of calculated angles in ROI1
figure(3); clf; axis off; polaraxes; hold on;
set(figure(3), 'Color', 'w');
polarhistogram(deg2rad(RES(RES(:, 1) == 1, 7)), -pi/2:pi/180*5:pi/2, 'EdgeColor', 'none', 'FaceAlpha', 1, 'Normalization', 'probability');
polarscatter(mean(deg2rad(RES(RES(:, 1) == 1, 7))), 0.3, 100, [0, 0.4470, 0.7410], 'filled');
set(gca, 'Box', 'on', 'FontSize', 20, 'LineWidth', 1, 'ThetaTick', -90:30:90, 'RTick', 0:0.1:0.3);
legend(['ROI1 (N=' num2str(sum(RES(:, 1) == 1)) ')'], 'location', 'westoutside');
axis([-90 90 0 0.3]);

% Creates polarhistogram of calculated angles in ROI2
figure(4); clf; axis off; polaraxes; hold on;
set(figure(4), 'Color', 'w');
polarhistogram(deg2rad(RES(RES(:, 1) == 2, 7)), -pi/2:pi/180*5:pi/2, 'EdgeColor', 'none', 'FaceAlpha', 1, 'FaceColor', [0.8500, 0.3250, 0.0980], 'Normalization', 'probability');
polarscatter(mean(deg2rad(RES(RES(:, 1) == 2, 7))), 0.3, 100, [0.8500, 0.3250, 0.0980], 'filled');
disp(['ANGLES in ROI1 = ' num2str(mean(RES(RES(:, 1) == 1, 7))) ' +- ' num2str(std(RES(RES(:, 1) == 1, 7))) ' °']);
disp(['ANGLES in ROI2 = ' num2str(mean(RES(RES(:, 1) == 2, 7))) ' +- ' num2str(std(RES(RES(:, 1) == 2, 7))) ' °']);
[~, p, D] = kstest2(RES(RES(:, 1) == 1, 7), RES(RES(:, 1) == 2, 7));
set(gca, 'Box', 'on', 'FontSize', 20, 'LineWidth', 1, 'ThetaTick', -90:30:90, 'RTick', 0:0.1:0.3);
legend(['ROI2 (N='  num2str(sum(RES(:, 1) == 2)) ')'], 'location', 'westoutside');
text(3*pi/4, 0.44, ['p=' num2str(p) '\newline D=' num2str(D)], 'FontSize', 20, 'FontWeight', 'bold')
axis([-90 90 0 0.3]);