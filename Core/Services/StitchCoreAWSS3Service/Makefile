all: prepare build
git:
	git init
	git add .
	git commit --allow-empty -m "init"
lint:
	swiftlint
clean:
	swift package --build-path ../../../.build clean
build:
	swift build --build-path ../../../.build -Xcc -I../../../vendor/MobileSDKs/include/libbson-1.0/ -Xcc -I../../../vendor/MobileSDKs/include/libmongoc-1.0
resolve:
	swift package --build-path ../../../.build resolve
update:
	swift package --build-path ../../../.build update
test:
	# temporary until a fix is in for .brew dependency for libmongoc
	xcodebuild test -workspace ../../../Stitch.xcworkspace/ -scheme StitchCoreAWSS3Service-Package -configuration Debug -destination "platform=iOS Simulator,name=iPhone 7,OS=11.2"
project:
	swift package generate-xcodeproj --xcconfig-overrides StitchCoreAWSS3Service.xcconfig
prepare: git resolve project
