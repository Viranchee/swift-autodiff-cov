# $BUILDFOLDER Ninja+cmark-RelWithDebInfoAssert+llvm-RelWithDebInfoAssert+swift-RelWithDebInfoAssertCoverage+stdlib-RelWithDebInfoAssert
BUILDFOLDER=BuildFolder
OUTPUTFILE=coverage
# Build instrumented compiler
swift/utils/update-checkout --scheme=main --clone-with-ssh
swift/utils/build-script --skip-build-benchmarks --skip-ios --skip-watchos --skip-tvos --swift-darwin-supported-archs "$(uname -m)" \
--sccache --swift-disable-dead-stripping --release-debuginfo --swift-analyze-code-coverage merged --build-subdir=$$BUILDFOLDER

# Run AutoDiff only tests
llvm-project/llvm/utils/lit/lit.py -s -vv ./build/$BUILDFOLDER/swift-macosx-arm64/test-macosx-arm64/AutoDiff --filter AutoDiff

find . -name "*.profraw" # The list of generated profdata files and a file in apple/swift repo folder + tests from llvm folder. Ignore them.

# Generate profdata from profraw files
build/$BUILDFOLDER/llvm-macosx-arm64/bin/llvm-profdata \
merge -sparse \
./swift/SwiftCompilerSources/default.profraw \
./build/$BUILDFOLDER/swift-macosx-arm64/tools/swift-compatibility-symbols/default.profraw \
./build/$BUILDFOLDER/swift-macosx-arm64/swift-test-results/arm64-apple-macosx10.13/swift-13565508600948082819_0.profraw \
./build/$BUILDFOLDER/swift-macosx-arm64/swift-test-results/arm64-apple-macosx10.13/swift-13565508600948082819_1.profraw \
./build/$BUILDFOLDER/swift-macosx-arm64/swift-test-results/arm64-apple-macosx10.13/swift-6755654451690607605_3.profraw \
./build/$BUILDFOLDER/swift-macosx-arm64/swift-test-results/arm64-apple-macosx10.13/swift-13565508600948082819_3.profraw \
./build/$BUILDFOLDER/swift-macosx-arm64/swift-test-results/arm64-apple-macosx10.13/swift-6755654451690607605_1.profraw \
./build/$BUILDFOLDER/swift-macosx-arm64/swift-test-results/arm64-apple-macosx10.13/swift-13565508600948082819_2.profraw \
./build/$BUILDFOLDER/swift-macosx-arm64/stdlib/public/SwiftOnoneSupport/default.profraw \
./build/$BUILDFOLDER/swift-macosx-arm64/stdlib/public/StringProcessing/default.profraw \
./build/$BUILDFOLDER/swift-macosx-arm64/stdlib/public/Distributed/default.profraw \
./build/$BUILDFOLDER/swift-macosx-arm64/stdlib/public/libexec/swift-backtrace/default.profraw \
./build/$BUILDFOLDER/swift-macosx-arm64/stdlib/public/Cxx/std/default.profraw \
./build/$BUILDFOLDER/swift-macosx-arm64/stdlib/public/Cxx/default.profraw \
./build/$BUILDFOLDER/swift-macosx-arm64/stdlib/public/RegexBuilder/default.profraw \
./build/$BUILDFOLDER/swift-macosx-arm64/stdlib/public/Concurrency/default.profraw \
./build/$BUILDFOLDER/swift-macosx-arm64/stdlib/public/RegexParser/default.profraw \
./build/$BUILDFOLDER/swift-macosx-arm64/stdlib/public/Backtracing/default.profraw \
./build/$BUILDFOLDER/swift-macosx-arm64/stdlib/public/Differentiation/default.profraw \
./build/$BUILDFOLDER/swift-macosx-arm64/stdlib/public/Observation/Sources/Observation/default.profraw \
./build/$BUILDFOLDER/swift-macosx-arm64/stdlib/private/SwiftReflectionTest/default.profraw \
./build/$BUILDFOLDER/swift-macosx-arm64/stdlib/private/DifferentiationUnittest/default.profraw \
./build/$BUILDFOLDER/swift-macosx-arm64/stdlib/private/SwiftPrivateLibcExtras/default.profraw \
./build/$BUILDFOLDER/swift-macosx-arm64/stdlib/private/SwiftPrivate/default.profraw \
./build/$BUILDFOLDER/swift-macosx-arm64/stdlib/private/StdlibUnittest/default.profraw \
./build/$BUILDFOLDER/swift-macosx-arm64/stdlib/private/OSLog/default.profraw \
./build/$BUILDFOLDER/swift-macosx-arm64/localization/default.profraw \
-o $OUTPUTFILE.profdata
# These profdata files failed to merge:
# ./build/$BUILDFOLDER/swift-macosx-arm64/stdlib/public/core/default.profraw \
# ./build/$BUILDFOLDER/swift-macosx-arm64/stdlib/public/Platform/default.profraw \
# ./build/$BUILDFOLDER/swift-macosx-arm64/stdlib/private/RuntimeUnittest/default.profraw \
# ./build/$BUILDFOLDER/swift-macosx-arm64/stdlib/private/SwiftPrivateThreadExtras/default.profraw \
# ./build/$BUILDFOLDER/swift-macosx-arm64/stdlib/private/StdlibUnittestFoundationExtras/default.profraw \

# Run llvm-cov
../llvm/buildlld/bin/llvm-cov show -format=html -output-dir=/Volumes/compiler/projects/diffonly-cov -instr-profile=$OUTPUTFILE.profdata --show-directory-coverage -object build/$BUILDFOLDER/swift-macosx-arm64/bin/swift

# Remove the profdata file
rm $OUTPUTFILE.profdata
pushd /Volumes/compiler/projects/diffonly-cov
# Open the generated html file
open index.html
# Git push 
git add .
git commit -m "Update coverage"
git push origin main
popd