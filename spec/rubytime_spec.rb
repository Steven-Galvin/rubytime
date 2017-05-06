require 'spec_helper'

RSpec.describe Rubytime do
  it 'has a version number' do
    expect(Rubytime::VERSION).not_to be nil
  end

  describe Rubytime::DBO do
    describe '#exec' do
      let(:dbo) { Rubytime::DBO.new('faketable') }
      it 'passes commands to the database' do
        sql = 'SELECT * FROM information_schema.columns LIMIT 1;'
        expect(dbo.exec(sql)).to be_a(PG::Result)
      end
    end

    describe '#exec_params' do
      let(:dbo) { Rubytime::DBO.new('faketable') }
      it 'passes commands to the database' do
        sql = 'SELECT * FROM information_schema.columns LIMIT $1;'
        expect(dbo.exec_params(sql, ['1'])).to be_a(PG::Result)
      end
    end

    describe '#columns' do
      let(:dbo) { Rubytime::DBO.new('faketable') }
      it 'fetches column names from the database' do
        rval = { a: 'method1', b: 'method2' }
        allow(dbo).to receive(:exec).with(/select column_name/) { rval }
        expect(dbo.columns).to match_array(%i[method1 method2])
      end

      it 'caches the results of the column lookup' do
        rval = { a: 'method1', b: 'method2' }
        allow(dbo).to(receive(:exec).with(/select column_name/).once) { rval }
        dbo.columns
        expect(dbo.columns).to match_array(%i[method1 method2])
      end
    end

    describe '#all' do
      let(:dbo) { Rubytime::DBO.new('faketable') }
      it 'makes a select all statement' do
        allow(dbo).to receive(:exec).with(/faketable/) { |arg| arg }
        expect(dbo.all).to eq('SELECT * FROM faketable;')
      end
    end

    describe '#delete' do
      let(:dbo) { Rubytime::DBO.new('faketable') }
      it 'makes a delete statement' do
        allow(dbo).to receive(:exec).with(/faketable/) { |arg| arg }
        expect(dbo.delete('1')).to eq('DELETE FROM faketable WHERE id = 1;')
      end
    end

    describe '#find_by' do
      let(:dbo) { Rubytime::DBO.new('faketable') }
      it 'makes a select ... where statement' do
        allow(dbo).to receive(:exec).with(/faketable/) { |arg| arg }
        expected = "SELECT * FROM faketable WHERE name = 'Foo';"
        expect(dbo.find_by(:name, 'Foo')).to eq(expected)
      end

      it 'accepts strings or symbols as keys' do
        allow(dbo).to receive(:exec).with(/faketable/) { |arg| arg }
        expected = "SELECT * FROM faketable WHERE name = 'Foo';"
        expect(dbo.find_by('name', 'Foo')).to eq(expected)
      end
    end

    describe '#update' do
      let(:dbo) { Rubytime::DBO.new('faketable') }
      it 'generates an update statement' do
        allow(dbo).to receive(:columns) { %i[id phasers] }
        allow(dbo).to receive(:exec).with(/faketable/) { |arg| arg }
        expected = "UPDATE faketable SET phasers = 'stun' WHERE id = 1;"
        expect(dbo.update(1, phasers: 'stun')).to eq(expected)
      end

      it 'fills in "modified" column if present' do
        allow(dbo).to receive(:exec).with(/faketable/) { |arg| arg }
        allow(dbo).to receive(:columns) { %i[id phasers modified] }
        t = Time.now
        Timecop.freeze(t) do
          expected = "UPDATE faketable SET phasers = 'stun',"\
            " modified = '#{t}' WHERE id = 1;"
          expect(dbo.update(1, phasers: 'stun')).to eq(expected)
        end
      end
    end

    describe '#save' do
      let(:dbo) { Rubytime::DBO.new('faketable') }
      it 'generates an insert statement' do
        allow(dbo).to receive(:exec_params)
          .with(/faketable/, ['Foo']) { |arg| arg }
        allow(dbo).to receive(:columns) { %i[id name] }
        expected = 'INSERT INTO faketable (name) VALUES ($1) returning id;'
        expect(dbo.save(name: 'Foo')).to eq(expected)
      end

      it 'generates a kvp for each argument' do
        allow(dbo).to receive(:exec_params)
          .with(/faketable/, %w[foo bar]) { |arg| arg }
        allow(dbo).to receive(:columns) { %i[id a b] }
        ex = 'INSERT INTO faketable (a, b) VALUES ($1, $2) returning id;'
        expect(dbo.save(a: 'foo', b: 'bar')).to eq(ex)
      end

      it 'fills in the "created" field if present' do
        allow(dbo).to receive(:columns) { %i[id a created] }
        t = Time.now
        Timecop.freeze(t) do
          allow(dbo).to receive(:exec_params)
            .with(/faketable/, ['foo', t]) { |arg| arg }
          e = 'INSERT INTO faketable (a, created) VALUES ($1, $2) returning id;'
          expect(dbo.save(a: 'foo')).to eq(e)
        end
      end
    end

    describe '#where' do
      let(:dbo) { Rubytime::DBO.new('faketable') }
      it 'generates a select statement' do
        allow(dbo).to receive(:exec).with(/faketable/) { |arg| arg }
        e = 'SELECT * FROM faketable;'
        expect(dbo.where).to eq(e)
      end

      it 'generates a select statement with conditions' do
        allow(dbo).to receive(:exec).with(/faketable/) { |arg| arg }
        e = "SELECT * FROM faketable WHERE '1' = '1';"
        expect(dbo.where("'1'" => 1)).to eq(e)
      end

      it 'generates a select statement with conditions (alt syntax)' do
        allow(dbo).to receive(:exec).with(/faketable/) { |arg| arg }
        e = "SELECT * FROM faketable WHERE '1' = '1';"
        expect(dbo.where(conditions: { "'1'" => 1 })).to eq(e)
      end

      it 'includes parent associations' do
        allow(dbo).to receive(:exec).with(/faketable/) { |arg| arg }
        e = 'SELECT * FROM faketable LEFT JOIN others AS parent ON ('\
          'faketable.other_id = parent.id);'
        expect(dbo.where(conditions: {}, p_include: :others)).to eq(e)
      end

      it 'includes child associations' do
        allow(dbo).to receive(:exec).with(/faketable/) { |arg| arg }
        # the table name is chopped here because it's expected to be plural
        # real name inflection is out of scope
        e = 'SELECT * FROM faketable LEFT JOIN others AS child ON ('\
          'faketable.id = child.faketabl_id);'
        expect(dbo.where(conditions: {}, c_include: :others)).to eq(e)
      end

      it 'selects individual fields' do
        allow(dbo).to receive(:exec).with(/faketable/) { |arg| arg }
        e = "SELECT f1, f2 FROM faketable WHERE f1 = '1';"
        expect(dbo.where(conditions: { f1: 1 }, fields: %i[f1 f2])).to eq(e)
      end
    end
  end
end
