alchemy.controller("imageModal", ['$scope', '$upload', '$modalInstance', 'assets', 'Util', 'Messages',
    function($scope, $upload, $modalInstance, assets, Util, Messages) {
        var BYTES_PER_MEGABYTE = 1048576;

        $scope.assets = assets;

        $scope.upload = function(file) {
            if ( file[0].size >= BYTES_PER_MEGABYTE * 3 ) {
                $scope.imageAlert = {
                                    type: "warning",
                                    msg: Messages.Warnings.MAX_IMAGE_SIZE,
                                    close: function() { $scope.imageAlert = null }
                               };
                return;
            }

            $upload.upload({
                url: '/assets',
                method: 'POST',
                file: file,
                fileFormDataName: 'image'
            }).progress(function(evt) {
                var progress = evt.loaded / evt.total;
                $scope.imageUploading = progress;
            }).success(function(data) {
                $scope.imageUploading = false;
                $scope.assets.push(data);
            }).error(function(error) {
                $scope.imageUploading = false;
                Util.showRailsError(error);
            });
        };

        $scope.cancel = function() {
            $modalInstance.dismiss('cancel');
        };

        $scope.setNodeAsset = function(asset) {
            $modalInstance.close(asset);
        };
    }
]);