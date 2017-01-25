package centaur.db;
// Generated 25-Jan-2017 11:43:53 by Hibernate Tools 5.2.0.CR1

import java.math.BigDecimal;

/**
 * Subarea generated by hbm2java
 */
public class Subarea implements java.io.Serializable {

	private int idSubcatchment;
	private Subcatchment subcatchment;
	private BigDecimal NImperv;
	private BigDecimal NPerv;
	private BigDecimal SImperv;
	private BigDecimal SPerv;
	private BigDecimal pctZero;
	private String routeTo;
	private BigDecimal pctRouted;

	public Subarea() {
	}

	public Subarea(Subcatchment subcatchment) {
		this.subcatchment = subcatchment;
	}

	public Subarea(Subcatchment subcatchment, BigDecimal NImperv, BigDecimal NPerv, BigDecimal SImperv,
			BigDecimal SPerv, BigDecimal pctZero, String routeTo, BigDecimal pctRouted) {
		this.subcatchment = subcatchment;
		this.NImperv = NImperv;
		this.NPerv = NPerv;
		this.SImperv = SImperv;
		this.SPerv = SPerv;
		this.pctZero = pctZero;
		this.routeTo = routeTo;
		this.pctRouted = pctRouted;
	}

	public int getIdSubcatchment() {
		return this.idSubcatchment;
	}

	public void setIdSubcatchment(int idSubcatchment) {
		this.idSubcatchment = idSubcatchment;
	}

	public Subcatchment getSubcatchment() {
		return this.subcatchment;
	}

	public void setSubcatchment(Subcatchment subcatchment) {
		this.subcatchment = subcatchment;
	}

	public BigDecimal getNImperv() {
		return this.NImperv;
	}

	public void setNImperv(BigDecimal NImperv) {
		this.NImperv = NImperv;
	}

	public BigDecimal getNPerv() {
		return this.NPerv;
	}

	public void setNPerv(BigDecimal NPerv) {
		this.NPerv = NPerv;
	}

	public BigDecimal getSImperv() {
		return this.SImperv;
	}

	public void setSImperv(BigDecimal SImperv) {
		this.SImperv = SImperv;
	}

	public BigDecimal getSPerv() {
		return this.SPerv;
	}

	public void setSPerv(BigDecimal SPerv) {
		this.SPerv = SPerv;
	}

	public BigDecimal getPctZero() {
		return this.pctZero;
	}

	public void setPctZero(BigDecimal pctZero) {
		this.pctZero = pctZero;
	}

	public String getRouteTo() {
		return this.routeTo;
	}

	public void setRouteTo(String routeTo) {
		this.routeTo = routeTo;
	}

	public BigDecimal getPctRouted() {
		return this.pctRouted;
	}

	public void setPctRouted(BigDecimal pctRouted) {
		this.pctRouted = pctRouted;
	}

}
