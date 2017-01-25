package centaur.db;
// Generated 25-Jan-2017 11:43:53 by Hibernate Tools 5.2.0.CR1

import java.math.BigDecimal;

/**
 * Coordinates generated by hbm2java
 */
public class Coordinates implements java.io.Serializable {

	private int idNode;
	private Node node;
	private BigDecimal x;
	private BigDecimal y;

	public Coordinates() {
	}

	public Coordinates(Node node) {
		this.node = node;
	}

	public Coordinates(Node node, BigDecimal x, BigDecimal y) {
		this.node = node;
		this.x = x;
		this.y = y;
	}

	public int getIdNode() {
		return this.idNode;
	}

	public void setIdNode(int idNode) {
		this.idNode = idNode;
	}

	public Node getNode() {
		return this.node;
	}

	public void setNode(Node node) {
		this.node = node;
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
