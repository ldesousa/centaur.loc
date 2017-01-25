package centaur.db;
// Generated 25-Jan-2017 11:43:53 by Hibernate Tools 5.2.0.CR1

import java.math.BigDecimal;

/**
 * CurveParameter generated by hbm2java
 */
public class CurveParameter implements java.io.Serializable {

	private int id;
	private Curve curve;
	private BigDecimal x;
	private BigDecimal y;

	public CurveParameter() {
	}

	public CurveParameter(int id) {
		this.id = id;
	}

	public CurveParameter(int id, Curve curve, BigDecimal x, BigDecimal y) {
		this.id = id;
		this.curve = curve;
		this.x = x;
		this.y = y;
	}

	public int getId() {
		return this.id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public Curve getCurve() {
		return this.curve;
	}

	public void setCurve(Curve curve) {
		this.curve = curve;
	}

	public BigDecimal getX() {
		return this.x;
	}

	public void setX(BigDecimal x) {
		this.x = x;
	}

	public BigDecimal getY() {
		return this.y;
	}

	public void setY(BigDecimal y) {
		this.y = y;
	}

}
