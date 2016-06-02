import Ember from 'ember';

export default Ember.Service.extend({
  showRead: true,
  page: 1,
  pageSize: 20,
  sort: '-date,id',
  selectedElement: null,

  read: Ember.computed('showRead', function() {
    return this.get('showRead') === false ? false : null;
  }),

  favorite: Ember.computed('selectedElement', function() {
    return this.get('selectedElement') === 'favorites' ? true : null;
  }),

  folder_id: Ember.computed('selectedElement', function() {
    if(this.get('selectedElement.constructor.modelName') === 'folder') {
      return this.get('selectedElement.id');
    }
    else {
      return null;
    }
  }),

  feed_id: Ember.computed('selectedElement', function() {
    if(this.get('selectedElement.constructor.modelName') === 'feed') {
      return this.get('selectedElement.id');
    }
    else {
      return null;
    }
  }),


  selectModel(model) {
    this.set('page', 1);
    this.set('selectedElement', model);
  },

  toggleReadVisibility() {
    this.set('showRead', !this.get('showRead'));
  },


  generateQueryData() {
    var query = {
      page: this.get('page'),
      page_size: this.get('pageSize'),
      sort: this.get('sort'),
      filter: {
        read: this.get('read'),
        favorite: this.get('favorite')
      }
    };

    if(this.get('folder_id')) {
      query.folder_id = this.get('folder_id');
    }

    if(this.get('feed_id')) {
      query.feed_id = this.get('feed_id');
    }

    return query;
  },

  filterItem(item) {
    if(this.get('read') === false && item.get('read') && !item.get('open')) {
      return false;
    }

    if(this.get('favorite') === true && !item.get('favorite')) {
      return false;
    }

    if(this.get('folder_id') && item.get('feed.folder.id') !== this.get('folder_id')) {
      return false;
    }

    if(this.get('feed_id') && item.get('feed.id') !== this.get('feed_id')) {
      return false;
    }

    return true;
  }
});
