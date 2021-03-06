Class kutac.monitor.task.Builder Extends %SYS.Task.Definition
{

/// This method is responsible for executing the task.<br>
/// At the scheduled time, the Task Manager creates an instance of this object,
/// sets any property values using the stored "settings" for the task, and then
/// invokes this method to execute the task.<br>
/// In order to execute a real task, override this method in a subclass.
Method OnTask() As %Status
{
	s tSC=$$$OK
	try {
		set cubes("CurrentSysDataDB")=""
		set cubes("HistoryPerfData")=""
		set cubes("HistoryPerfDataWD")=""
		set cubes("HistorySysData")=""
		set cubes("HistorySysDataDB")=""
		s cube=""
		for {
			s cube=$o(cubes(cube)) q:cube=""
			$$$THROWONERROR(tSC,##class(%DeepSee.Utils).%BuildCube(cube,,0))
			s ^kutac("SYSMON","LastCubeBuild")=$lb(tSC,$h)
		}		
	} catch (e) {
		set tSC=$$$ADDSC(tSC,e.AsStatus())	
		s ^kutac("SYSMON","LastCubeBuild")=$lb(e.DisplayString(),$h)
	}
	Quit tSC
}

/// d ##class(kutac.monitor.task.Builder).Setup()
ClassMethod Setup()
{
		try {
			set tTask=##class(%SYS.Task).%New()
			set tTask.Name="Rebuild SYSMON Cubes"
			set tTask.DailyFrequency=1
			set tTask.DailyFrequencyTime=0
			set tTask.DailyIncrement=35		// run every 15 minutes
			set tTask.DailyStartTime=28800	// 8AM
			set tTask.DailyEndTime=64800	// 6PM
			if ($p($h,",",2) >= 64800)
				set tTask.StartDate=+$h+1
			else
				set tTask.StartDate=+$h
			set tTask.Description="Rebuild System Monitor Cubes"
			set tTask.NameSpace=$namespace
			set tTask.TaskClass="kutac.monitor.task.Builder"
			$$$THROWONERROR(tSC,tTask.%Save())
			do ##class(%SYS.Task).Resume(tTask.%Id())
			do ##class(%SYS.Task).RunNow(tTask.%Id())
		} catch (ex) {
			w !,ex.DisplayString()
		}
	quit
}

}

