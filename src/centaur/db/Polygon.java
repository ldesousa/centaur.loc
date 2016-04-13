package centaur.db;
// Generated Apr 13, 2016 3:20:15 PM by Hibernate Tools 4.3.1.Final

import java.math.BigDecimal;

/**
 * Polygon generated by hbm2java
 */
public class Polygon implements java.io.Serializable {

	private Integer id;
	private Subcatchment subcatchment;
	private BigDecimal x;
	private BigDecimal y;

	public Polygon() {
	}

	public Polygon(Subcatchment subcatchment, BigDecimal x, BigDecimal y) {
		this.subcatchment = subcatchment;
		this.x = x;
		this.y = y;
	}

	public Integer getId() {
		return this.id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Subcatchment getSubcatchment() {
		return this.subcatchment;
	}

	public void setSubcatchment(Subcatchment subcatchment) {
		this.subcatchment = subcatchment;
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
