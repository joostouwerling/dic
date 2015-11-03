%
% E. Werkema <e.werkema@student.rug.nl>, University of Groningen
% Date created: September 21, 2015
%
% This function calculates the strain components.  
%
% Input:
%
% * output_dic - direct output of the DIC program
%
% Output:
% * Two matrices with the corresponding strain components. The first method 
%   is calculated directly while the second one is smoothed with a least 
%   squares fitting technique.
%
% function [ output ] = strain( output_dic )
%

function [ output ] = strain( output_dic )
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SECTION 1
    % Configuration of variables
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    if (isfield(output_dic, 'config')==0)
        width = size(output_dic.result,2);
        height = size(output_dic.result,1);
        subset_w =11;
        subset_h = 11;
        strain_w = 9;
        strain_h = 9;
    else
        width = size(output_dic.config.gridpoints.cols, 2);
        height = size(output_dic.config.gridpoints.rows, 2);
        subset_w = output_dic.config.subsetSize.width;
        subset_h = output_dic.config.subsetSize.width;
        strain_w = 11;
        strain_h = 11;
    end
    
    output = struct( ...
        'strain_direct', struct( ...
            'e_xx', NaN(height, width), ...
            'e_xy', NaN(height, width), ...
            'e_yy', NaN(height, width), ...
            'avg', struct( ...
                'e_xx', 0, ...
                'e_xy', 0, ...
                'e_yy', 0 ...
            ) ...
        ), ...
        'strain', struct( ...
            'e_xx', NaN(floor(height/subset_h),floor(width/subset_w)), ...
            'e_xy', NaN(floor(height/subset_h),floor(width/subset_w)), ...
            'e_yy', NaN(floor(height/subset_h),floor(width/subset_w)), ...
            'avg', struct( ...
                'e_xx', 0, ...
                'e_xy', 0, ...
                'e_yy', 0 ...
            ) ...
        ), ...
        'coefficient', struct( ...
            'a0', NaN(floor(height/subset_h),floor(width/subset_w)), ...
            'a1', NaN(floor(height/subset_h),floor(width/subset_w)), ...
            'a2', NaN(floor(height/subset_h),floor(width/subset_w)), ...
            'b0', NaN(floor(height/subset_h),floor(width/subset_w)), ...
            'b1', NaN(floor(height/subset_h),floor(width/subset_w)), ...
            'b2', NaN(floor(height/subset_h),floor(width/subset_w)) ...
        ) ...
    );

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SECTION 2
    % Calculation of strains using the direct method
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    for row = 1:height
        for col = 1:width
            if (output_dic.result(row,col)==0)
                % Exx strain component
                output.strain_direct.e_xx(row,col) = 0.5 * (2*output_dic.p.u_x(row,col) + ...
                (output_dic.p.u_x(row,col))^2 + (output_dic.p.v_x(row,col))^2);
                % Exy strain component
                output.strain_direct.e_xy(row,col) = 0.5 * ( ...
                output_dic.p.u_y(row,col) + output_dic.p.v_x(row,col) + ...
                output_dic.p.u_x(row,col)*output_dic.p.u_y(row,col) +  ... 
                output_dic.p.v_x(row,col)*output_dic.p.v_y(row,col));
                % Eyy strain component
                output.strain_direct.e_yy(row,col) = 0.5 * (2*output_dic.p.v_y(row,col) + ...
                (output_dic.p.u_y(row,col))^2 + (output_dic.p.v_y(row,col))^2);
            end
        end
    end
    
    % Calculate average strains
    output.strain_direct.avg.e_xx = mean(mean(output.strain_direct.e_xx(output_dic.result==0)));
    output.strain_direct.avg.e_xy = mean(mean(output.strain_direct.e_xy(output_dic.result==0)));
    output.strain_direct.avg.e_yy = mean(mean(output.strain_direct.e_yy(output_dic.result==0)));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SECTION 3
    % Plot the strains from the direct method
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    close all;
    
    figure(1);
    
    subplot(2,2,1);
    contourf(output.strain_direct.e_xx);
    title('Strain component Exx');
    axis square;
    colorbar
    
    subplot(2,2,2);
    contourf(output.strain_direct.e_xy);
    title('Strain shear component Exy');
    axis square;
    colorbar
    
    subplot(2,2,3);
    contourf(output.strain_direct.e_yy);
    title('Strain component Eyy');
    axis square;
    colorbar
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SECTION 4
    % Computation of strains using the pointwise least squares 
    % algorithm
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Least squares algorithm
    for row = 1:floor(height/strain_h)
        for col = 1:floor(width/strain_w)
            rows = (row-1)*strain_h+1:(row-1)*strain_h+strain_h;
            cols = (col-1)*strain_w+1:(col-1)*strain_w+strain_w;
            
            all_rows = ones(strain_h,1)*rows*subset_h;
            all_rows = all_rows(:)';
            
            all_cols = cols'*ones(1,strain_w)*subset_w;
            all_cols = all_cols(:)';
            
            u = output_dic.p.u(rows,cols);
            u = u(:)';
            index_u_inf = (u == Inf);
            u(index_u_inf) = [];
            
            points = [ones(strain_h*strain_w,1) all_rows' all_cols' ];
            
            A = points;
            A(index_u_inf, :) = [];
            a = A\u';
            
            output.coefficient.a0(row,col) = a(1);
            output.coefficient.a1(row,col) = a(2);
            output.coefficient.a2(row,col) = a(3);
            
            v = output_dic.p.v(rows,cols);
            v = v(:)';
            index_v_inf = (v == Inf);
            v(index_v_inf) = [];
            
            B = points;
            B(index_v_inf, :) = [];
            b = B\v';
            
            output.coefficient.b0(row,col) = b(1);
            output.coefficient.b1(row,col) = b(2);
            output.coefficient.b2(row,col) = b(3);
        end
    end
    
    u = zeros(floor(height/strain_h), floor(width/strain_w));
    v = zeros(floor(height/strain_h), floor(width/strain_w));
     % Calculate strains from interpolation
    for row = 1:floor(height/strain_h)
        for col = 1:floor(width/strain_w)
            x = (row-1)*strain_h+1:(row-1)*strain_h+strain_h;
            y = ((col-1)*strain_w+1:(col-1)*strain_w+strain_w)';
            xVals = ones(size(x))'*x*subset_w;
            yVals = y*ones(size(y))'*subset_h;
            u(x,y) = output.coefficient.a0(row,col) + output.coefficient.a1(row,col)*xVals ...
               + output.coefficient.a2(row,col)*yVals;
            v(x,y) = output.coefficient.b0(row,col) + output.coefficient.b1(row,col)*xVals ...
               + output.coefficient.b2(row,col)*yVals;

            % Exx strain component
            output.strain.e_xx(x,y) = 0.5 * (2*output.coefficient.a1(row,col) + ...
            (output.coefficient.a1(row,col))^2 + (output.coefficient.b1(row,col))^2);
            % Exy strain component
            output.strain.e_xy(x,y) = 0.5 * ( ...
            output.coefficient.a2(row,col) + output.coefficient.b1(row,col) + ...
            output.coefficient.a1(row,col)*output.coefficient.a2(row,col) +  ... 
            output.coefficient.b1(row,col)*output.coefficient.b2(row,col));
            % Eyy strain component
            output.strain.e_yy(x,y) = 0.5 * (2*output.coefficient.b2(row,col) + ...
            (output.coefficient.a2(row,col))^2 + (output.coefficient.b2(row,col))^2);
        end
    end
    
    figure(3);
    
    subplot(2,1,1);
    contourf(v);
    colorbar
    title('Displacement v calculated from interpolation');
    axis square;
    
    subplot(2,1,2);
    contourf(output_dic.p.v);
    colorbar
    title('Displacement v calculated from DIC');
    axis square;
    
     % Calculate average strains
    output.strain.avg.e_xx = mean(mean(output.strain.e_xx));
    output.strain.avg.e_xy = mean(mean(output.strain.e_xy));
    output.strain.avg.e_yy = mean(mean(output.strain.e_yy));

    figure(2);
    
    x = 1:floor(width/strain_w)*strain_w;
    y = 1:floor(height/strain_h)*strain_h;
    
    subplot(2,2,1);
    contourf(x,y,output.strain.e_xx);
    title('Strain component Exx');
    axis square;
    colorbar
    
    subplot(2,2,2);
    contourf(x,y,output.strain.e_xy);
    title('Strain component Exy');
    axis square;
    colorbar
    
    subplot(2,2,3);
    contourf(x,y,output.strain.e_yy);
    title('Strain component Eyy');
    axis square;
    colorbar
    
end

