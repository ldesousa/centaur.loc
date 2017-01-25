package centaur.db;
// Generated 25-Jan-2017 11:43:53 by Hibernate Tools 5.2.0.CR1

import java.math.BigDecimal;

/**
 * Xsection generated by hbm2java
 */
public class Xsection implements java.io.Serializable {

	private int idLink;
	private Link link;
	private String shape;
	private BigDecimal geom1;
	private BigDecimal geom2;
	private BigDecimal geom3;
	private BigDecimal geom4;
	private BigDecimal barrels;
	private BigDecimal culvert;

	public Xsection() {
	}

	public Xsection(Link link) {
		this.link = link;
	}

	public Xsection(Link link, String shape, BigDecimal geom1, BigDecimal geom2, BigDecimal geom3, BigDecimal geom4,
			BigDecimal barrels, BigDecimal culvert) {
		this.link = link;
		this.shape = shape;
		this.geom1 = geom1;
		this.geom2 = geom2;
		this.geom3 = geom3;
		this.geom4 = geom4;
		this.barrels = barrels;
		this.culvert = culvert;
	}

	public int getIdLink() {
		return this.idLink;
	}

	public void setIdLink(int idLink) {
		this.idLink = idLink;
	}

	public Link getLink() {
		return this.link;
	}

	public void setLink(Link link) {
		this.link = link;
	}

	public String getShape() {
		return this.shape;
	}

	public void setShape(String shape) {
		this.shape = shape;
	}

	public BigDecimal getGeom1() {
		return this.geom1;
	}

	public void setGeom1(BigDecimal geom1) {
		this.geom1 = geom1;
	}

	public BigDecimal getGeom2() {
		return this.geom2;
	}

	public void setGeom2(BigDecimal geom2) {
		this.geom2 = geom2;
	}

	public BigDecimal getGeom3() {
		return this.geom3;
	}

	public void setGeom3(BigDecimal geom3) {
		this.geom3 = geom3;
	}

	public BigDecimal getGeom4() {
		return this.geom4;
	}

	public void setGeom4(BigDecimal geom4) {
		this.geom4 = geom4;
	}

	public BigDecimal getBarrels() {
		return this.barrels;
	}

	public void setBarrels(BigDecimal barrels) {
		this.barrels = barrels;
	}

	public BigDecimal getCulvert() {
		return this.culvert;
	}

	public void setCulvert(BigDecimal culvert) {
		this.culvert = culvert;
	}

}
