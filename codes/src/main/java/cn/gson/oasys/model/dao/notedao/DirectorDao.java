package cn.gson.oasys.model.dao.notedao;

import cn.gson.oasys.model.entity.user.User;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.PagingAndSortingRepository;

import cn.gson.oasys.model.entity.note.Director;
import cn.gson.oasys.model.entity.note.Note;

public interface DirectorDao  extends PagingAndSortingRepository<Director, Long>{

    /**获取当前用户的外部通讯录数量
     *
     * @param user
     * @return int
     */
    @Query("select count(*) from Director d where d.myuser=?1")
    int getDirectorByUserId(User user);

}
