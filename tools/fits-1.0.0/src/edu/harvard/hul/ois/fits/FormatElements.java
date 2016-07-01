//
// Copyright (c) 2016 by The President and Fellows of Harvard College
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License. You may obtain a copy of the License at:
// http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software distributed under the License is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permission and limitations under the License.
//

package edu.harvard.hul.ois.fits;

public enum FormatElements {
	size ("fileSize"),
	filename ("fileName"),
	mimeType ("mimeType"),
	location ("location"),
	bitRate ("bitRate"),
	dateCreated ("dateCreated"),
	dateModified ("dateModified"),
	formatProfile ("formatProfile"),
	format ("format"),
	duration ("duration");

	private String ebucoreName;

	FormatElements(String ebucoreName) {
        this.ebucoreName = ebucoreName;
    }

    public String getEbucoreName () {
        return ebucoreName;
    }

    static public FormatElements lookup(String name) {
    	FormatElements retMethod = null;
    	for(FormatElements method : FormatElements.values()) {
    		if (method.name().equals(name)) {
    			retMethod = method;
    			break;
    		}
    	}
    	return retMethod;
    }

}
