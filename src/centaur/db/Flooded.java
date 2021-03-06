package centaur.db;
// Generated 06-Apr-2017 15:50:29 by Hibernate Tools 5.2.0.CR1

import java.math.BigDecimal;

/**
 * Flooded generated by hbm2java
 */
public class Flooded implements java.io.Serializable {

	private Integer idFlooded;
	private Candidate candidate;
	private Link link;
	private BigDecimal volumeFraction;
	private BigDecimal QPrac;
	private BigDecimal energyLineOffset;

	public Flooded() {
	}

	public Flooded(Candidate candidate, Link link) {
		this.candidate = candidate;
		this.link = link;
	}

	public Flooded(Candidate candidate, Link link, BigDecimal volumeFraction, BigDecimal QPrac,
			BigDecimal energyLineOffset) {
		this.candidate = candidate;
		this.link = link;
		this.volumeFraction = volumeFraction;
		this.QPrac = QPrac;
		this.energyLineOffset = energyLineOffset;
	}

	public Integer getIdFlooded() {
		return this.idFlooded;
	}

	public void setIdFlooded(Integer idFlooded) {
		this.idFlooded = idFlooded;
	}

	public Candidate getCandidate() {
		return this.candidate;
	}

	public void setCandidate(Candidate candidate) {
		this.candidate = candidate;
	}

	public Link getLink() {
		return this.link;
	}

	public void setLink(Link link) {
		this.link = link;
	}

	public BigDecimal getVolumeFraction() {
		return this.volumeFraction;
	}

	public void setVolumeFraction(BigDecimal volumeFraction) {
		this.volumeFraction = volumeFraction;
	}

	public BigDecimal getQPrac() {
		return this.QPrac;
	}

	public void setQPrac(BigDecimal QPrac) {
		this.QPrac = QPrac;
	}

	public BigDecimal getEnergyLineOffset() {
		return this.energyLineOffset;
	}

	public void setEnergyLineOffset(BigDecimal energyLineOffset) {
		this.energyLineOffset = energyLineOffset;
	}

}
