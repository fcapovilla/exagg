import Ember from 'ember';
import EmberUploader from 'ember-uploader';

export default EmberUploader.FileField.extend({
  session: Ember.inject.service('session'),
  url: '',

  filesDidChange: function(files) {
    var that = this;

    this.get('session').authorize('authorizer:token', (headerName, headerValue) => {
      var uploadUrl = that.get('url');
      var headers = {};
      headers[headerName] = headerValue;

      var uploader = EmberUploader.Uploader.create({
        url: uploadUrl,
        ajax: function(url, params, method) {
          var settings = this.ajaxSettings(url, params, method);
          settings.headers = headers;
          return this._ajax(settings);
        }
      });

      uploader.on('didUpload', function(response) {
        that.sendAction('onUpload', response);
      });

      if (!Ember.isEmpty(files)) {
        uploader.upload(files[0]);
      }
    });
  }
});
