 rows = 1:0.01:2;
 cols = 1:0.01:2;
  pointValues2 = zeros(size(rows, 2), size(cols,2));
    
 for row = 1:size(rows,2)
        for col = 1:size(cols,2)
            r = floor(rows(row));
            c = floor(cols(col));
            x2 = cols(col) - c;
            y2 = rows(row) - r;
            pointValues2(row,col) = a00*x2*y2;
        end
 end
 pointValues2