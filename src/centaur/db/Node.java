package centaur.db;
// Generated 25-Jan-2017 14:43:53 by Hibernate Tools 5.2.0.CR1

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.HashSet;
import java.util.Set;

/**
 * Node generated by hbm2java
 */
public class Node implements java.io.Serializable {

	private Integer id;
	private BigDecimal elevation;
	private String name;
	private Boolean taken;
	//private Serializable geom;
	private Junction junction;
	private Outfall outfall;
	private Set linksForIdNodeTo = new HashSet(0);
	private Candidate candidate;
	private Set linksForIdNodeFrom = new HashSet(0);
	private Storage storage;
	private Set subcatchments = new HashSet(0);
	private Coordinates coordinates;

	public Node() {
	}

	public Node(BigDecimal elevation, String name, Boolean taken, /*Serializable geom,*/ Junction junction, Outfall outfall,
			Set linksForIdNodeTo, Candidate candidate, Set linksForIdNodeFrom, Storage storage, Set subcatchments,
			Coordinates coordinates) {
		this.elevation = elevation;
		this.name = name;
		this.taken = taken;
		//this.geom = geom;
		this.junction = junction;
		this.outfall = outfall;
		this.linksForIdNodeTo = linksForIdNodeTo;
		this.candidate = candidate;
		this.linksForIdNodeFrom = linksForIdNodeFrom;
		this.storage = storage;
		this.subcatchments = subcatchments;
		this.coordinates = coordinates;
	}

	public Integer getId() {
		return this.id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public BigDecimal getElevation() {
		return this.elevation;
	}

	public void setElevation(BigDecimal elevation) {
		this.elevation = elevation;
	}

	public String getName() {
		return this.name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public Boolean getTaken() {
		return this.taken;
	}

	public void setTaken(Boolean taken) {
		this.taken = taken;
	}

	/*public Serializable getGeom() {
		return this.geom;
	}

	public void setGeom(Serializable geom) {
		this.geom = geom;
	}*/

	public Junction getJunction() {
		return this.junction;
	}

	public void setJunction(Junction junction) {
		this.junction = junction;
	}

	public Outfall getOutfall() {
		return this.outfall;
	}

	public void setOutfall(Outfall outfall) {
		this.outfall = outfall;
	}

	public Set getLinksForIdNodeTo() {
		return this.linksForIdNodeTo;
	}

	public void setLinksForIdNodeTo(Set linksForIdNodeTo) {
		this.linksForIdNodeTo = linksForIdNodeTo;
	}

	public Candidate getCandidate() {
		return this.candidate;
	}

	public void setCandidate(Candidate candidate) {
		this.candidate = candidate;
	}

	public Set getLinksForIdNodeFrom() {
		return this.linksForIdNodeFrom;
	}

	public void setLinksForIdNodeFrom(Set linksForIdNodeFrom) {
		this.linksForIdNodeFrom = linksForIdNodeFrom;
	}

	public Storage getStorage() {
		return this.storage;
	}

	public void setStorage(Storage storage) {
		this.storage = storage;
	}

	public Set getSubcatchments() {
		return this.subcatchments;
	}

	public void setSubcatchments(Set subcatchments) {
		this.subcatchments = subcatchments;
	}

	public Coordinates getCoordinates() {
		return this.coordinates;
	}

	public void setCoordinates(Coordinates coordinates) {
		this.coordinates = coordinates;
	}

}
