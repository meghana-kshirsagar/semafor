
package edu.cmu.cs.lti.ark.fn.parsing;

import edu.cmu.cs.lti.ark.util.ds.GuideFeatureSpan;
import java.util.HashMap;
import com.google.common.io.InputSupplier;
import com.google.common.io.CharStreams;
import com.google.common.base.Charsets;
import com.google.common.collect.Multimap;
import com.google.common.collect.HashMultimap;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Collection;
import java.util.List;
import java.util.ArrayList;

import static java.lang.Integer.parseInt;
import static java.lang.Double.parseDouble;

public class GuideSystem {

    public static final int SEMLINK = 0;
    public static final int EXEMPLAR = 1;
    private static final String DEFAULT_SEMLINK_FILE = "semlink_all.frame.elements";
    private static final String DEFAULT_EXEMPLARS_FILE = "exemplars_all.frame.elements";
    private static final String DEFAULT_SENTENCES_FILE = "fn.all.sentences";
    private static int type;
    InputSupplier<? extends InputStream> candidateInputSupplier;
    private static HashMap<String, Integer> sentHash;
	private static Multimap<Integer, GuideFeatureSpan> sentGuidespanMap;

	public GuideSystem(int type) {
        this.type = type;
		try{
			loadGuides();
		} catch (IOException e) { e.printStackTrace(); throw new RuntimeException(e); }
	}

    private static InputSupplier<InputStream> DEFAULT_SENTENCE_SUPPLIER = new InputSupplier<InputStream>() {
        @Override public InputStream getInput() throws IOException {
            return getClass().getClassLoader().getResourceAsStream(DEFAULT_SENTENCES_FILE);
    } };

    private static InputSupplier<InputStream> DEFAULT_SEMLINK_SUPPLIER = new InputSupplier<InputStream>() {
        @Override public InputStream getInput() throws IOException {
            return getClass().getClassLoader().getResourceAsStream(DEFAULT_SEMLINK_FILE);
    } };

    private static InputSupplier<InputStream> DEFAULT_EXEMPLARS_SUPPLIER = new InputSupplier<InputStream>() {
        @Override public InputStream getInput() throws IOException {
            return getClass().getClassLoader().getResourceAsStream(DEFAULT_EXEMPLARS_FILE);
    } };

    public static void loadGuides() throws IOException {
        if(sentHash == null) {
			sentHash = new HashMap<String, Integer>();
			sentGuidespanMap = HashMultimap.create();
            readSentences(CharStreams.newReaderSupplier(DEFAULT_SENTENCE_SUPPLIER, Charsets.UTF_8));
            if(type == SEMLINK)
                readFEfile(CharStreams.newReaderSupplier(DEFAULT_SEMLINK_SUPPLIER, Charsets.UTF_8));
            else
                readFEfile(CharStreams.newReaderSupplier(DEFAULT_EXEMPLARS_SUPPLIER, Charsets.UTF_8));
        }
    }

    public static void readSentences(InputSupplier<InputStreamReader> input) throws IOException {
        final List<String> sents = CharStreams.readLines(input);
		System.err.println("Loaded input sents..."+sents.size());
        int counter=0;
        for (String line: sents) {
            sentHash.put(line.trim(), counter++);
        }
		System.err.println("Loaded Sentences map ..."+sentHash.size());
    }

    public static void readFEfile(InputSupplier<InputStreamReader> input) throws IOException {
        final List<String> felines = CharStreams.readLines(input);
		System.err.println("Loaded input FEs..."+felines.size());
        for (String feline: felines) {
        	String[] tokens = feline.trim().split("\t");
        	int numSpans = parseInt(tokens[2]);
			if(numSpans > 1) {
	            final int sentNum = parseInt(tokens[7]);
    	        sentGuidespanMap.putAll(sentNum, decomposeFELine(feline));
			}
        }
		System.err.println("Loaded FE guide spans..."+sentGuidespanMap.size());
    }

    protected static List<GuideFeatureSpan> decomposeFELine(String frameElementsLine) {
        ArrayList<GuideFeatureSpan> spanList = new ArrayList<GuideFeatureSpan>();
        String[] tokens = frameElementsLine.trim().split("\t");
        int rank = parseInt(tokens[0]);
        double score = parseDouble(tokens[1]);
        String frName = tokens[3];
        for (int i = 8; i < tokens.length; i += 2) {
            final String feName = tokens[i];
            final String feSpan = tokens[i+1];
            int feStart, feEnd;
            if (feSpan.contains(":")) {
                String[] rangeParts = feSpan.split(":");
                feStart = parseInt(rangeParts[0]);
                feEnd = parseInt(rangeParts[1]);
            }
            else {
                feStart = feEnd = parseInt(feSpan);
            }
            spanList.add(new GuideFeatureSpan(feStart, feEnd, frName, feName));
        }
        return spanList;
    }

	public Collection<GuideFeatureSpan> getGuideSpans(String sentence) {
		if(sentHash.get(sentence) == null) {
			System.out.println("No guides found for sentence: "+sentence);
			return null;
		}
		else if(sentGuidespanMap.get(sentHash.get(sentence)) == null) {
			System.out.println("No spans found for sentence: "+sentence);
			return null;
		}

		return sentGuidespanMap.get(sentHash.get(sentence));
	}

}
