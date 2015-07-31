module Trail
  class Record
    def new_record?
      @new_record != false
    end

    # :nodoc:
    def new_record=(@new_record)
    end

    def deleted?
      @deleted == true
    end

    def save
      if new_record?
        _create
      else
        _update
      end
    end

    private def _create
      Time.now.tap do |time|
        self.created_at ||= time
        self.updated_at ||= time
      end

      attributes = to_hash.delete_if do |k, v|
        k == self.class.primary_key && v == nil
      end

      id = Record.connection.insert(
        self.class.table_name,
        attributes,
        self.class.primary_key,
        self.class.primary_key_type
      )

      if id
        self.id = id
        @new_record = false
      else
        false
      end
    end

    private def _update
      self.updated_at = Time.now

      attributes = to_hash.delete_if do |k, _v|
        k == self.class.primary_key
      end

      self.class.where({ self.class.primary_key => id }).update_all(attributes)
    end

    def delete
      self.class.delete(id)
      @deleted = true
    end

    #def destroy
    #  delete
    #end

    def self.create(attributes)
      build(attributes).tap { |record| record.save }
    end

    def self.delete(id)
      where({ primary_key => id }).delete_all
    end

    #def self.destroy(id)
    #  find(id).tap { |record| record.destroy }
    #end
  end
end
