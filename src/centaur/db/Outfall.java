package centaur.db;
// Generated 06-Apr-2017 15:50:29 by Hibernate Tools 5.2.0.CR1

/**
 * Outfall generated by hbm2java
 */
public class Outfall implements java.io.Serializable {

	private int idNode;
	private Node node;
	private String type;
	private String stageDate;
	private Boolean gated;
	private String routeTo;

	public Outfall() {
	}

	public Outfall(Node node) {
		this.node = node;
	}

	public Outfall(Node node, String type, String stageDate, Boolean gated, String routeTo) {
		this.node = node;
		this.type = type;
		this.stageDate = stageDate;
		this.gated = gated;
		this.routeTo = routeTo;
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

	public String getType() {
		return this.type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getStageDate() {
		return this.stageDate;
	}

	public void setStageDate(String stageDate) {
		this.stageDate = stageDate;
	}

	public Boolean getGated() {
		return this.gated;
	}

	public void setGated(Boolean gated) {
		this.gated = gated;
	}

	public String getRouteTo() {
		return this.routeTo;
	}

	public void setRouteTo(String routeTo) {
		this.routeTo = routeTo;
	}

}
