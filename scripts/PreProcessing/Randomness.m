%% Randomness analyser 
%This script has been written to analyse the information content of the
%bits within the raw images 

%% Specification
clear 
clc
close all
file_format = ""; % Specify the file format here (e.g tiff/tif/jpg)
Path_to_data = "";% Specify the path to the sample scan image stack you want to use for randomness analysis
Path_to_save = "";% Specify the path to directory in which bit randomness profiles will be saved 
ext = "*." + file_format;
%% Analysis
cd(Path_to_data)
dirPattern = fullfile(mydir,ext);
all = dir(dirPattern);
for z=1 : length(all)
    if all(z).isdir ~= 1
        fprintf("File %s \n",all(z).name);
        % Reading the image
        I  = imread(all(z).name);
        m = size(I,1);
        n = size(I,2);
        BI = de2bi(uint16(I));
        clear I;
        size_dif = abs(size(BI,2) - 16);
        if size_dif ~= 0
            BI = [BI, zeros(size(BI,1),size_dif)];
        end
        % Separating the bits into 16 arrays and finding q_b(1)
        q_b = zeros(1,size(BI,2));
        for i=1 : size(BI,2)
            Bi{size(BI,2)-i+1} = BI(:,i);
            q_b(i) = length(Bi{i}(Bi{i} ==1))/(length(Bi{i}));
        end
        % Plotting
        hold on;
        subplot1 = subplot(3,1,1);
        index = 1:1:16;
        plot(index,q_b,'b'); title('Frequency of 1s $q_{bit}(1)$','FontSize',15,'Interpreter','latex');hold on;
        box(subplot1,'on');
        set(subplot1,'LineWidth',1,'XGrid','on','XTickLabel',{'b_{16}','b_{14}','b_{12}','b_{10}','b_{8}','b_{6}','b_{4}','b_{2}','b{0}'},'YGrid','on');
        % Spatial correlation
        cor_l = zeros(1,length(Bi));
        cor_t = zeros(1,length(Bi));
        for i=1:length(Bi)
            M = reshape(Bi{i},m,n);
            x1 = zeros(1,(m-2)*(n-2));
            x2 = zeros(1,(m-2)*(n-2));
            x3 = zeros(1,(m-2)*(n-2));
            for j=2:size(M,1)-1
                for k=2:size(M,2)-1
                    % The bit itself
                    x1(1,(m-2)*k+j) = M(j,k);
                    % The bit to the left
                    x2(1,(m-2)*k+j) = M(j,k-1);
                    % The bit to the right
                    x3(1,(m-2)*k+j) = M(j-1,k);
                end
            end
            m1 = cov(x1,x2);
            cor_l(i) = m1(1,2)/sqrt(m1(1,1)*m1(2,2));
            m2 = cov(x1,x3);
            cor_t(i) = m2(1,2)/sqrt(m2(1,1)*m2(2,2));
        end
        % Plotting again
        hold on;
        subplot2 = subplot(3,1,2); 
        plot(index,cor_l,'b'); title('Left bit correlation','FontSize',15,'Interpreter','latex');hold on;
        set(subplot2,'LineWidth',1,'XGrid','on','XTickLabel',{'b_{16}','b_{14}','b_{12}','b_{10}','b_{8}','b_{6}','b_{4}','b_{2}','b{0}'},'YGrid','on');
        box(subplot2,'on');
        hold on;
        subplot3 = subplot(3,1,3);
        plot(index,cor_t,'b'); title('Top bit correlation','FontSize',15,'Interpreter','latex'); hold on;
        set(subplot3,'LineWidth',1,'XGrid','on','XTickLabel',{'b_{16}','b_{14}','b_{12}','b_{10}','b_{8}','b_{6}','b_{4}','b_{2}','b{0}'},'YGrid','on');
        box(subplot3,'on');
    end
end
cd(Path_to_save)
saveas(gcf,"BitRandomProfile.png")

        