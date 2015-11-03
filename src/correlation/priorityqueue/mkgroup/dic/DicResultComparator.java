/**
 * A comparator for DicResult. Lower coefficients come first.
 *
 * @author J.T. Ouwerling <j.t.ouwerling@student.rug.nl>
 * @since 10th June, 2015
 */

package mkgroup.dic;

import java.util.Comparator;
import mkgroup.dic.DicResult;

public class DicResultComparator implements Comparator<DicResult> {

	@Override
	public int compare(DicResult x, DicResult y) {
		/* if < 0, x before y, if 0, equal, if > 1, y before x */
		if(x.coefficient < y.coefficient) {
			return -1;
		}
		if(x.coefficient == y.coefficient) {
			return 0;
		}
		return 1;
	}

}