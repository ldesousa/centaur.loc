package centaur.db;
// Generated Jun 17, 2016 8:52:13 AM by Hibernate Tools 4.3.1.Final

import java.math.BigDecimal;
import java.util.HashSet;
import java.util.Set;

/**
 * Raingage generated by hbm2java
 */
public class Raingage implements java.io.Serializable {

	private int id;
	private String format;
	private String interval;
	private BigDecimal scf;
	private String source;
	private Set subcatchments = new HashSet(0);

	public Raingage() {
	}

	public Raingage(int id) {
		this.id = id;
	}

	public Raingage(int id, String format, String interval, BigDecimal scf, String source, Set subcatchments) {
		this.id = id;
		this.format = format;
		this.interval = interval;
		this.scf = scf;
		this.source = source;
		this.subcatchments = subcatchments;
	}

	public int getId() {
		return this.id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getFormat() {
		return this.format;
	}

	public void setFormat(String format) {
		this.format = format;
	}

	public String getInterval() {
		return this.interval;
	}

	public void setInterval(String interval) {
		this.interval = interval;
	}

	public BigDecimal getScf() {
		return this.scf;
	}

	public void setScf(BigDecimal scf) {
		this.scf = scf;
	}

	public String getSource() {
		return this.source;
	}

	public void setSource(String source) {
		this.source = source;
	}

	public Set getSubcatchments() {
		return this.subcatchments;
	}

	public void setSubcatchments(Set subcatchments) {
		this.subcatchments = subcatchments;
	}

}
