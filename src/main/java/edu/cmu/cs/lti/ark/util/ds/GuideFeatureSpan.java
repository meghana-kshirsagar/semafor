
package edu.cmu.cs.lti.ark.util.ds;

import java.io.Serializable;

public class GuideFeatureSpan extends Range0Based { 
	private String role;
	private String frame;

	public GuideFeatureSpan(int beginChar, int endChar, String frame, String role) {
		super(beginChar, endChar, true);
		this.frame = frame;
		this.role = role;
	}

	public String toString() {
		String res = "("+start+","+end+") "+frame+":"+role;
		return res;
	}

	public String getRole() {
		return role;
	}

	public String getFrame() {
		return frame;
	}
}
