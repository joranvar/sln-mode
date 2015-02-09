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

;; TODO: Add ProjectConfigurationPlatforms too, when adding a project
;; TODO? Create non-existing project file from here

(defun sln-test--insert-empty-csharp-project (assembly-name project-uuid)
  (insert (s-lex-format
	   "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<Project ToolsVersion=\"12.0\" DefaultTargets=\"Build\" xmlns=\"http://schemas.microsoft.com/developer/msbuild/2003\">
  <Import Project=\"$(MSBuildExtensionsPath)\\$(MSBuildToolsVersion)\\Microsoft.Common.props\" Condition=\"Exists('$(MSBuildExtensionsPath)\\$(MSBuildToolsVersion)\\Microsoft.Common.props')\" />
  <PropertyGroup>
    <Configuration Condition=\" '$(Configuration)' == '' \">Debug</Configuration>
    <Platform Condition=\" '$(Platform)' == '' \">AnyCPU</Platform>
    <ProjectGuid>{${project-uuid}}</ProjectGuid>
    <OutputType>Library</OutputType>
    <AppDesignerFolder>Properties</AppDesignerFolder>
    <RootNamespace>${assembly-name}</RootNamespace>
    <AssemblyName>${assembly-name}</AssemblyName>
    <TargetFrameworkVersion>v4.5.2</TargetFrameworkVersion>
  </PropertyGroup>
</Project>")))

(defun sln-test--create-temp-project-file (assembly-name project-uuid)
    (let ((file-name (make-temp-file
		      (expand-file-name "sln-test"
					(or small-temporary-file-directory
					    temporary-file-directory)) nil ".csproj")))
      (with-temp-file file-name
	(sln-test--insert-empty-csharp-project assembly-name project-uuid)
	file-name)))

(ert-deftest sln-add-project--in-empty-solution--should-add-it-right-on-top ()
  (with-temp-buffer
    (sln-test--insert-empty-solution)
    (sln-add-project "NewProjectFile.csproj" "NewProjectName" "ProjectUUID")
    (goto-char (point-min))
    (forward-line 4)
    (should (equal (thing-at-point 'line) "Project(\"{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}\") = \"NewProjectName\", \"NewProjectFile.csproj\", \"{ProjectUUID}\"\n"))
    (forward-line)
    (should (equal (thing-at-point 'line) "EndProject\n"))
    ))

(ert-deftest sln-add-project--in-empty-solution--should-add-it-right-on-top-2 ()
  (with-temp-buffer
    (sln-test--insert-empty-solution)
    (sln-add-project "DifferentProjectName.csproj" nil "ProjectUUID")
    (goto-char (point-min))
    (forward-line 4)
    (should (equal (thing-at-point 'line) "Project(\"{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}\") = \"DifferentProjectName\", \"DifferentProjectName.csproj\", \"{ProjectUUID}\"\n"))
    (forward-line)
    (should (equal (thing-at-point 'line) "EndProject\n"))
    ))

(ert-deftest sln-add-project--when-missing-file-name--should-signal-error ()
  (with-temp-buffer
    (sln-test--insert-empty-solution)
    (should-error (sln-add-project nil))))

(ert-deftest sln-add-project--with-empty-file-name--should-signal-error ()
  (with-temp-buffer
    (sln-test--insert-empty-solution)
    (should-error (sln-add-project ""))))

(ert-deftest sln-add-project--when-project-file-does-not-exist-and-uuid-is-not-given--should-generate-uuid ()
  (with-temp-buffer
    (sln-test--insert-empty-solution)
    (sln-add-project "unknown.csproj")
    (goto-char (point-min))
    (forward-line 4)
    (should (re-search-forward "Project(\"{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}\") = \"unknown\", \"unknown.csproj\", \"{[0-9a-fA-F]\\{8\\}-[0-9a-fA-F]\\{4\\}-[0-9a-fA-F]\\{4\\}-[0-9a-fA-F]\\{4\\}-[0-9a-fA-F]\\{12\\}}\"" nil t))
    ))

(ert-deftest sln-add-project--with-existing-project-file--should-get-uuid-from-there ()
  (with-temp-buffer
    (sln-test--insert-empty-solution)
    (let ((project-file-name (sln-test--create-temp-project-file "Assembly.Name" "7ed17131-5d69-4798-ab36-d646119df350")))
      (sln-add-project project-file-name "TempProjectName")
      (goto-char (point-min))
      (forward-line 4)
      (should (equal (thing-at-point 'line)
		     (s-lex-format "Project(\"{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}\") = \"TempProjectName\", \"${project-file-name}\", \"{7ed17131-5d69-4798-ab36-d646119df350}\"\n")))
    (forward-line)
    (should (equal (thing-at-point 'line) "EndProject\n")))))

(ert-deftest sln--get-project-uuid-from-file--gets-project-uuid-from-file ()
  (let ((project-file-name (sln-test--create-temp-project-file "Assembly.Name" "ProjectGUID")))
    (should (equal (sln--get-project-uuid-from-file project-file-name) "ProjectGUID"))))
