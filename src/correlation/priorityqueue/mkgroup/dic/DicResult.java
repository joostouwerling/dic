/**
 * A wrapper for a result of DIC optimization
 *
 * @author J.T. Ouwerling <j.t.ouwerling@student.rug.nl>
 * @since 10th June, 2015
 */
package mkgroup.dic;

public class DicResult {
    
    public double coefficient;
    public int row;
    public int col;
    
    /**
     * Necessary for Matlab or so.
     */
    public DicResult() {
        coefficient = 0;
        row = 0;
        col = 0;
    }
    
    public DicResult(double coef, int r, int c) {
        coefficient = coef;
        row = r;
        col = c;
    }
    
}