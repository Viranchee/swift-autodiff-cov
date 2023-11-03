rm -rf /Volumes/compiler/projects/diffonly-cov/coverage
rm /Volumes/compiler/projects/diffonly-cov/index.*
rm /Volumes/compiler/projects/diffonly-cov/sty*


# Regexes: Match swift/*/*/SILOptimizer/Differentiation/*
# llvm-cov Regex engine does not support backtracking in regex, or, the not operator
# llvm-cov also does not have option to only allow filename regex search only
SwiftDir="swift/(include/swift|lib)"
notStartS="[A-RT-Z]/?.*"
notStartSi="S[a-hj-z]+.*"
notStartSILO="SIL[A-NP-Z]+.*"
SILFolder="SIL/.*"
notStartD="[A-CE-Z].*"

# Execute llvm-cov: 
# there are only limited files, turned off show-directory-coverage because 
../llvm/buildlld/bin/llvm-cov show \
--project-title="$1" \
-format=html \
-output-dir=/Volumes/compiler/projects/swift-autodiff-cov \
-instr-profile=.vscode/coverage/nov2.profdata \
-object build/Ninja+cmark-RelWithDebInfoAssert+llvm-RelWithDebInfoAssert+swift-RelWithDebInfoAssertCoverage+stdlib-RelWithDebInfoAssert/swift-macosx-arm64/bin/swiftc \
--ignore-filename-regex "swift/tools/*" \
--ignore-filename-regex "swift/stdlib/*" \
--ignore-filename-regex "build/Ninja*" \
--ignore-filename-regex "llvm-project/*" \
--ignore-filename-regex $SwiftDir/$notStartS \
--ignore-filename-regex $SwiftDir/$notStartSi \
--ignore-filename-regex $SwiftDir/$notStartSILO \
--ignore-filename-regex $SwiftDir/$SILFolder \
--ignore-filename-regex $SwiftDir/SILOptimizer/$notStartD \
--show-directory-coverage


# open /Volumes/compiler/projects/swift-autodiff-cov/index.*
