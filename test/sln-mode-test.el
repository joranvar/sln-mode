(defun sln-test--insert-empty-solution ()
  (insert "Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio 2013
VisualStudioVersion = 12.0.31101.0
MinimumVisualStudioVersion = 10.0.40219.1
Global
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Any CPU = Debug|Any CPU
		Release|Any CPU = Release|Any CPU
	EndGlobalSection
	GlobalSection(SolutionProperties) = preSolution
		HideSolutionNode = FALSE
	EndGlobalSection
EndGlobal
"))

(ert-deftest sln-add-project--in-empty-solution--should-add-it-right-on-top ()
  (unwind-protect
      (with-temp-buffer
	(sln-test--insert-empty-solution)
	(sln-add-project "NewProjectName")
	(goto-char (point-min))
	(forward-line 4)
	(should (equal (thing-at-point 'line) "Project(\"{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}\") = \"NewProjectName\", \"NewProjectName.csproj\", \"{ProjectUUID}\"\n"))
	(forward-line)
	(should (equal (thing-at-point 'line) "EndProject\n"))
    nil)))

(ert-deftest sln-add-project--in-empty-solution--should-add-it-right-on-top-2 ()
  (unwind-protect
      (with-temp-buffer
	(sln-test--insert-empty-solution)
	(sln-add-project "DifferentProjectName")
	(goto-char (point-min))
	(forward-line 4)
	(should (equal (thing-at-point 'line) "Project(\"{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}\") = \"DifferentProjectName\", \"DifferentProjectName.csproj\", \"{ProjectUUID}\"\n"))
	(forward-line)
	(should (equal (thing-at-point 'line) "EndProject\n"))
    nil)))
