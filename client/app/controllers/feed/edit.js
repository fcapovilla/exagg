import Ember from 'ember';

export default Ember.Controller.extend({
  folderTitle: function() {
    return this.model.get('folder.title');
  }.property('model.folder.title'),

  actions: {
    saveFeed() {
      var that = this;
      this.store.queryRecord('folder', {filter: {title: this.get('folderTitle')}}).then(function(folders) {
        var folder = folders[0];

        // Create folder if it doesn't exist.
        if(!folder) {
          folder = that.store.createRecord('folder', {
            title: that.get('folderTitle'),
            position: 1
          });
        }

        folder.save().then(function() {
          that.model.set('folder', folder);
          that.model.save().then(function(feed) {
            that.transitionToRoute('feed', feed.id);
          });
        });
      });
    }
  }
});
