/**
*============================================================================
*  The Ohio State University Research Foundation, Emory University,
*  the University of Minnesota Supercomputing Institute
*
*  Distributed under the OSI-approved BSD 3-Clause License.
*  See http://ncip.github.com/cagrid-grid-incubation/LICENSE.txt for details.
*============================================================================
**/
/**
*============================================================================
*============================================================================
**/
package org.cagrid.monitor.command;

import java.lang.reflect.Constructor;

public class CommandUtils {
	public static Command loadCommand(String className) {
		Command commandToLoad = null;
		try {
			Class cls = Class.forName(className);
			Constructor ct = cls.getConstructor();
			commandToLoad = (Command) ct.newInstance();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return commandToLoad;
	}
}
