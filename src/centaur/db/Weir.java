package centaur.db;
// Generated Mar 18, 2016 9:34:12 AM by Hibernate Tools 4.3.1.Final

import java.math.BigDecimal;

/**
 * Weir generated by hbm2java
 */
public class Weir implements java.io.Serializable {

	private int idLink;
	private Link link;
	private String type;
	private BigDecimal crestHeight;
	private BigDecimal QCoeff;
	private Boolean gated;
	private BigDecimal endCon;
	private BigDecimal endCoeff;
	private Boolean surcharge;

	public Weir() {
	}

	public Weir(Link link) {
		this.link = link;
	}

	public Weir(Link link, String type, BigDecimal crestHeight, BigDecimal QCoeff, Boolean gated, BigDecimal endCon,
			BigDecimal endCoeff, Boolean surcharge) {
		this.link = link;
		this.type = type;
		this.crestHeight = crestHeight;
		this.QCoeff = QCoeff;
		this.gated = gated;
		this.endCon = endCon;
		this.endCoeff = endCoeff;
		this.surcharge = surcharge;
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

	public String getType() {
		return this.type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public BigDecimal getCrestHeight() {
		return this.crestHeight;
	}

	public void setCrestHeight(BigDecimal crestHeight) {
		this.crestHeight = crestHeight;
	}

	public BigDecimal getQCoeff() {
		return this.QCoeff;
	}

	public void setQCoeff(BigDecimal QCoeff) {
		this.QCoeff = QCoeff;
	}

	public Boolean getGated() {
		return this.gated;
	}

	public void setGated(Boolean gated) {
		this.gated = gated;
	}

	public BigDecimal getEndCon() {
		return this.endCon;
	}

	public void setEndCon(BigDecimal endCon) {
		this.endCon = endCon;
	}

	public BigDecimal getEndCoeff() {
		return this.endCoeff;
	}

	public void setEndCoeff(BigDecimal endCoeff) {
		this.endCoeff = endCoeff;
	}

	public Boolean getSurcharge() {
		return this.surcharge;
	}

	public void setSurcharge(Boolean surcharge) {
		this.surcharge = surcharge;
	}

}
